# frozen_string_literal: true

module Pubid
  module Iho
    # Parses IHO URNs back into identifiers through the documented
    # positional segment grammar (the same grammar the generator emits;
    # the segment table lives in the grammar header and the flavor notes):
    #
    #   urn:iho:<type>:<number>[:ed-<x.y.z>][:sup-<n>][:part-<X>]
    #     [:annex-<A>][:appendix-<B>][:<sub>][:vol-<n>][:issue-<n>]
    #     [:year-<yyyy>]
    #
    # Segment discipline (mirrors the ISO URN parser's strictness):
    # - the docnumber occupies every leading bare number segment up to
    #   the first marker, so a colon number ("158:100") round-trips
    #   without escaping;
    # - every other component is a marker-prefixed segment validated
    #   against its own value pattern — unknown, reordered or junk
    #   segments raise {Pubid::Errors::UrnParseError}, never
    #   mis-consume;
    # - the appendix subnumber is a bare digit atom allowed only
    #   directly after its appendix segment (a year is always
    #   marker-tagged, so a bare digit there can only be the subnumber);
    # - the issue is allowed only beside its volume and validated as
    #   digits.
    #
    # Legacy 2.0.x spellings remain decodable but are never emitted:
    # the bare a.b.c edition segment, the dotted keys part./annex./
    # suppl./ap./appendix./vol./issue. and the single-letter y. year tag
    # (the #637 scheme the positional grammar replaces; the legacy
    # appendix values stored the subnumber inside one string, "D-2",
    # which decodes into the two components).
    #
    # Examples:
    # - urn:iho:s:44:ed-5.0.0                  → IHO S-44 5.0.0
    # - urn:iho:s:100:ed-5.0.0:part-2          → IHO S-100 5.0.0 Part 2
    # - urn:iho:s:122:ed-1.0.0:appendix-D:2    → IHO S-122 1.0.0 Appendix D-2
    # - urn:iho:p:5:vol-2024                   → IHO P-5 Vol. 2024
    # - urn:iho:p:1:vol-30:issue-2             → IHO P-1 Vol. 30 (2)
    # - urn:iho:s:158:100                      → IHO S-158:100
    class UrnParser < Pubid::UrnParser::Base
      TYPE_LETTERS = %w[s p m b c].freeze

      # Marker => attribute, with the value pattern each marker's slot
      # accepts. The patterns mirror the grammar's own production rules
      # (upper-case letters are case-preserved; "part" allows the
      # digits-then-letters compound like "4a" beside a lone letter; the
      # volume takes any serial locator, yearbook years included).
      MARKERS = {
        "ed" => [:edition, /\A\d+\.\d+\.\d+\z/],
        "sup" => [:supplement, /\A\d+\z/],
        "part" => [:part, /\A(?:\d+[a-zA-Z]*|[A-Z])\z/],
        "annex" => [:annex, /\A[A-Z]\z/],
        "appendix" => [:appendix, /\A(?:[A-Z]|\d+)\z/],
        "vol" => [:volume, /\A\d+\z/],
        "issue" => [:issue, /\A\d+\z/],
        "year" => [:year, /\A(?:19|20)\d{2}\z/],
      }.freeze

      MARKER_RE = /\A(#{MARKERS.keys.join('|')})-(.+)\z/

      # Legacy dotted keys (deprecated; decodable, never emitted).
      # "ap" is the pre-positional appendix tag; "suppl" the pre-positional
      # supplement tag; "y" the pre-positional year tag — under the
      # serial-locator unification a year IS a volume, so the y. value
      # decodes into the volume.
      LEGACY_KEYS = {
        "part" => :part,
        "annex" => :annex,
        "suppl" => :supplement,
        "ap" => :appendix,
        "appendix" => :appendix,
        "vol" => :volume,
        "issue" => :issue,
        "y" => :volume,
      }.freeze

      LEGACY_RE = /\A([a-z]+)\.(.+)\z/

      # A bare a.b.c segment is the legacy edition encoding.
      LEGACY_EDITION_RE = /\A\d+\.\d+\.\d+\z/
      SUBNUMBER_RE = /\A\d+\z/
      # The docnumber's own charset: digits with : / - suffix runs.
      NUMBER_RE = /\A\d+(?:[:\/-]\d+)*\z/

      def parse_urn(urn)
        segments = split_parts(strip_namespace(urn))
        type_token = read_type!(segments, urn)
        attrs = { number: consume_number!(segments, urn) }
        consume_segments!(attrs, segments, urn)
        Builder.build({ type: type_token.upcase, **attrs })
      end

      private

      def read_type!(segments, urn)
        type_token = segments.shift.to_s.downcase
        return type_token if TYPE_LETTERS.include?(type_token)

        raise Pubid::Errors::UrnParseError,
              "Unknown IHO series #{type_token.inspect} in #{urn.inspect}"
      end

      def consume_segments!(attrs, segments, urn)
        until segments.empty?
          consume_segment!(attrs, segments, urn)
        end
      end

      # The number occupies every leading bare number segment; the first
      # segment that is not number-shaped ends it (and the segment loop
      # below decides whether it is a legal marker).
      def consume_number!(segments, urn)
        number = []
        while segments.first&.match?(NUMBER_RE)
          number << segments.shift
        end
        if number.empty?
          raise Pubid::Errors::UrnParseError,
                "Missing docnumber in #{urn.inspect}"
        end

        number.join(":")
      end

      def consume_segment!(attrs, segments, urn)
        segment = segments.shift
        case segment
        when MARKER_RE then consume_marker!(attrs, Regexp.last_match, segments, 
                                            urn)
        when LEGACY_RE then consume_legacy!(attrs, Regexp.last_match, urn)
        when LEGACY_EDITION_RE then store!(attrs, :edition, segment, urn)
        else raise_unexpected!(segment, urn)
        end
      end

      def raise_unexpected!(segment, urn)
        raise Pubid::Errors::UrnParseError,
              "Unexpected segment #{segment.inspect} in #{urn.inspect}"
      end

      # A marker segment: validate the value against the marker's own
      # pattern, store it, and claim the bare atom that follows an
      # appendix (its subnumber — the only bare atom allowed after a
      # marker).
      def consume_marker!(attrs, match, segments, urn)
        key, pattern = MARKERS.fetch(match[1])
        value = match[2]
        unless value.match?(pattern)
          raise Pubid::Errors::UrnParseError,
                "Invalid #{match[1]} value #{value.inspect} in #{urn.inspect}"
        end

        store!(attrs, key, value, urn)
        consume_subnumber!(attrs, key, segments, urn)
      end

      def consume_subnumber!(attrs, key, segments, urn)
        return unless key == :appendix && segments.first&.match?(SUBNUMBER_RE)

        store!(attrs, :appendix_subnumber, segments.shift, urn)
      end

      # Legacy dotted-key decode. The legacy appendix value stored the
      # subnumber inside one string ("appendix.D-2"); it decodes into the
      # two components.
      def consume_legacy!(attrs, match, urn)
        key = LEGACY_KEYS.fetch(match[1]) do
          raise Pubid::Errors::UrnParseError,
                "Unexpected segment #{match[0].inspect} in #{urn.inspect}"
        end

        store_legacy!(attrs, key, match[2], urn)
      end

      def store_legacy!(attrs, key, value, urn)
        sub = /\A([A-Z])-(\d+)\z/.match(value) if key == :appendix
        return store!(attrs, key, value, urn) unless sub

        store!(attrs, :appendix, sub[1], urn)
        store!(attrs, :appendix_subnumber, sub[2], urn)
      end

      def store!(attrs, key, value, urn)
        raise_if_duplicate(key, attrs, urn)
        attrs[key] = value
      end

      def raise_if_duplicate(key, attrs, urn)
        return unless attrs[key]

        raise Pubid::Errors::UrnParseError,
              "Duplicate #{key} segment in #{urn.inspect}"
      end
    end
  end
end
