# frozen_string_literal: true

module Pubid
  module Iho
    # Parses IHO URNs back into identifiers, both emitted schemes:
    #
    # == The adopted IHO MRN guidance form (the emission of every series)
    #
    #   urn:mrn:iho:pub:<type>:<name>[:<edition>][:<trailing atoms>...]
    #
    # - <type>: bathy / cb / reg / per / spec — the guidance publication
    #   types (the five S-11 Part C Ed 1.0.0 section 1.2 groups:
    #   Bathymetric Publications, Capacity Building Publications,
    #   Miscellaneous Publications, Periodic Publications, Standards and
    #   Specifications); each maps back to its series letter.
    # - <name>: sNNN — the lowercase series letter + number; the S-158
    #   member joins hyphenated (s158-102), the fleet extension of the
    #   guidance for compound publication numbers.
    # - <edition>: the bare dotted x.y.z right after the name (the
    #   guidance's canonical 4th segment; the S-98 precedent).
    # - The trailing atoms are the lowercase marker segments: a
    #   component's own edition rides as ed- right after it (the duality
    #   law), the Appendix subnumber hyphen-joins its appendix
    #   (appendix-D-2), values case-preserved. The guidance's bare
    #   correction/clarification slots (the s57:3:1 form) are not modeled
    #   faces — a bare digit tail segment rejects as unexpected.
    #
    # == The legacy positional form (decode-only for every series,
    #    emitted by none)
    #
    #   urn:iho:<type>:<number>[:ed-<x.y.z>][:sup-<n>][:part-<X>]
    #     [:spec-<n>[:specsub-<n>][:specvar-<X>]][:annex-<A>]
    #     [:appendix-<B>][:<sub>][:vol-<n>][:issue-<n>][:year-<yyyy>]
    #
    # Segment discipline (mirrors the ISO URN parser's strictness):
    # - the docnumber occupies the first bare number segment; a further
    #   bare digit segment binds product — the S-158 member number as
    #   its own segment ("urn:iho:s:158:100"), never glued into the
    #   number (issue #774);
    # - every other component is a marker-prefixed segment validated
    #   against its own value pattern — unknown, reordered or junk
    #   segments raise {Pubid::Errors::UrnParseError}, never
    #   mis-consume;
    # - the appendix subnumber is either the bare digit atom directly
    #   after its appendix segment (the legacy emission) or the
    #   hyphen-joined compound value ("appendix-D-2", the MRN emission);
    # - the issue is allowed only beside its volume and validated as
    #   digits;
    # - the S-4 spec atom is a child of its part (the citation letter
    #   rides the part- atom): specsub-/specvar- only after spec-, and
    #   no ed-/year- after a spec node (the spec rides its publication's
    #   edition; the section is derivable, never emitted).
    #
    # Legacy 2.0.x spellings remain decodable but are never emitted:
    # the bare a.b.c edition segment, the dotted keys part./annex./
    # suppl./ap./appendix./vol./issue. and the single-letter y. year tag
    # (the #637 scheme the positional grammar replaces; the legacy
    # appendix values stored the subnumber inside one string, "D-2",
    # which decodes into the two components).
    #
    # Both paths build through Builder.build — the S-158 alias
    # unification (a draft-era part-S-102 URN decodes to the product
    # identity) and every other semantic validation is shared with the
    # text parse.
    #
    # Examples:
    # - urn:mrn:iho:pub:spec:s44:5.0.0                  → IHO S-44 5.0.0
    # - urn:mrn:iho:pub:spec:s158-102:1.0.0             → IHO S-158:102 1.0.0
    # - urn:mrn:iho:pub:reg:m2:sup-1                    → IHO M-2 Sup 1
    # - urn:mrn:iho:pub:per:p1:vol-30:issue-2           → IHO P-1 Vol. 30 (2)
    # - urn:mrn:iho:pub:bathy:b12:3.0.0              → IHO B-12 3.0.0
    # - urn:mrn:iho:pub:cb:c51:6.0.0                 → IHO C-51 6.0.0
    # - urn:iho:s:44:ed-5.0.0                           → IHO S-44 5.0.0
    # - urn:iho:s:158:100:ed-1.0.0                      → IHO S-158:100 1.0.0
    # - urn:iho:s:4:ed-4.10.0:part-B:spec-401           → IHO S-4 4.10.0 B-401
    class UrnParser < Pubid::UrnParser::Base
      TYPE_LETTERS = %w[s p m b c].freeze

      # The guidance publication type -> series letter (the emission's
      # MRN_TYPES inverted): the five S-11 Part C groups onto their
      # series letters. An unknown type rejects.
      MRN_TYPE_LETTERS = { "spec" => "S", "per" => "P", "reg" => "M",
                           "bathy" => "B", "cb" => "C" }.freeze

      MRN_PREFIX = "urn:mrn:iho:pub:"
      # The publication name: the lowercase series letter + number, the
      # S-158 member hyphen-joined (s158-102).
      MRN_NAME_RE = /\A([spmbc])(\d+)(?:-(\d+))?\z/

      # Marker => attribute, with the value pattern each marker's slot
      # accepts. The patterns mirror the grammar's own production rules
      # (upper-case letters are case-preserved; "part" allows the
      # digits-then-letters compound like "4a" beside a lone letter; the
      # volume takes any serial locator, yearbook years included;
      # "appendix" allows the hyphen-joined compound "D-2" — the MRN
      # emission — which splits into the appendix and its subnumber).
      MARKERS = {
        "ed" => [:edition, /\A\d+\.\d+\.\d+\z/],
        "sup" => [:supplement, /\A\d+\z/],
        "part" => [:part, /\A(?:\d+[a-zA-Z]*|[A-Z]|[SPMBC]-\d+)\z/],
        "spec" => [:spec, /\A[1-6]\d\d\z/],
        "specsub" => [:spec_sub, /\A\d+\z/],
        "specvar" => [:spec_variant, /\A[A-Z]+\z/],
        "annex" => [:annex, /\A[A-Z]\z/],
        "appendix" => [:appendix, /\A(?:[A-Z](?:-\d+)?|\d+)\z/],
        "vol" => [:volume, /\A\d+\z/],
        "issue" => [:issue, /\A\d+\z/],
        "year" => [:year, /\A(?:19|20)\d{2}\z/],
      }.freeze

      MARKER_RE = /\A(#{MARKERS.keys.join('|')})-(.+)\z/

      # The positional markers: their attribute depends on the node they
      # follow (the component-edition duality).
      POSITIONAL_MARKERS = %i[edition year].freeze

      # The S-4 spec node and its children: specsub-/specvar- are only
      # allowed after their parent, and an S-4 spec rides its
      # publication's edition — no ed-/year- inside a spec.
      SPEC_NODES = %i[spec spec_sub spec_variant].freeze
      SPEC_PARENTS = %i[spec spec_sub].freeze

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
      # The further bare segments that bind the S-158 member number.
      CHECKS_SEGMENT_RE = /\A\d+\z/

      def parse_urn(urn)
        return parse_mrn_urn(urn) if urn.downcase.start_with?(MRN_PREFIX)

        parse_legacy_urn(urn)
      end

      private

      # The guidance-form decode: publication type, name (number +
      # optional S-158 member), the bare dotted edition, then the shared
      # marker machinery (the positional ed-/year- attachment included).
      # The body is NOT case-folded: values are case-preserved
      # (appendix-D-2, part-B); only the type token lowercases.
      def parse_mrn_urn(urn)
        segments = urn[MRN_PREFIX.length..].split(":")
        type_token = segments.shift.to_s.downcase
        letter = MRN_TYPE_LETTERS.fetch(type_token) do
          raise Pubid::Errors::UrnParseError,
                "Unknown IHO publication type #{type_token.inspect} " \
                "in #{urn.inspect}"
        end
        attrs = mrn_name_attributes!(segments, urn)
        # the bare dotted edition in the canonical 4th segment
        if segments.first&.match?(LEGACY_EDITION_RE)
          attrs[:edition] = segments.shift
        end
        ctx = { component: nil, edition_owner: nil }
        consume_segments!(attrs, segments, ctx, urn)
        build_identifier({ type: letter, **attrs }, urn)
      end

      # The name segment: sNNN, or s158-NNN with the S-158 member bound
      # as its own component. The series letter maps back through the
      # type token; the name carries only the number (and member).
      def mrn_name_attributes!(segments, urn)
        name = segments.shift.to_s
        match = MRN_NAME_RE.match(name)
        unless match
          raise Pubid::Errors::UrnParseError,
                "Unknown IHO publication name #{name.inspect} in #{urn.inspect}"
        end

        attrs = { number: match[2] }
        # the member designator rides the S-158 anchor; another series
        # rejects through the builder's anchor assert
        attrs[:product] = match[3] if match[3]
        attrs
      end

      # The legacy positional decode (the pre-guidance emission shape and
      # every legacy spelling it decodes; never emitted — all five series
      # carry a guidance type code).
      def parse_legacy_urn(urn)
        segments = split_parts(strip_namespace(urn))
        type_token = read_type!(segments, urn)
        attrs = consume_number!(segments, urn)
        # Positional context: the component the upcoming ed-/year- would
        # attach to, and the owner of the edition just consumed (a year
        # belongs to a component only when it follows that component's
        # own edition).
        ctx = { component: nil, edition_owner: nil }
        consume_segments!(attrs, segments, ctx, urn)
        build_identifier({ type: type_token.upcase, **attrs }, urn)
      end

      # The semantic validations the builder applies to the decoded shape
      # (the S-4 anchor, the citation letter, the S-158 checks anchor)
      # are URN validation at this layer: a URN that asserts a shape it
      # cannot carry is a malformed URN, and the raw ArgumentError stays
      # as the cause. The URN is the canonical shape, so the decoded
      # identifier drops the parse-only spelling face — a legacy
      # part-S-102 decode renders the canonical colon designator.
      def build_identifier(hash, urn)
        identifier = Builder.build(hash)
        identifier.product_face = nil
        identifier
      rescue ArgumentError => e
        raise Pubid::Errors::UrnParseError,
              "#{e.message} in #{urn.inspect}"
      end

      def read_type!(segments, urn)
        type_token = segments.shift.to_s.downcase
        return type_token if TYPE_LETTERS.include?(type_token)

        raise Pubid::Errors::UrnParseError,
              "Unknown IHO series #{type_token.inspect} in #{urn.inspect}"
      end

      def consume_segments!(attrs, segments, ctx, urn)
        until segments.empty?
          consume_segment!(attrs, segments, ctx, urn)
        end
      end

      # The first bare number segment is the docnumber; the next bare
      # digit segment binds the S-158 member number (product — the
      # member as its own segment, never glued into the number), and
      # anything else ends the number run (the segment loop below
      # decides whether it is a legal marker).
      def consume_number!(segments, urn)
        number = segments.shift.to_s
        unless number.match?(NUMBER_RE)
          raise Pubid::Errors::UrnParseError,
                "Missing docnumber in #{urn.inspect}"
        end

        attrs = { number: number }
        if segments.first&.match?(CHECKS_SEGMENT_RE)
          attrs[:product] = segments.shift
        end
        attrs
      end

      def consume_segment!(attrs, segments, ctx, urn)
        segment = segments.shift
        case segment
        when MARKER_RE then consume_marker!(segment, attrs, segments, ctx, urn)
        when LEGACY_RE then consume_legacy!(segment, attrs, urn)
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
      # appendix (its subnumber — the legacy emission's only bare atom
      # after a marker; the MRN emission hyphen-joins the compound
      # instead). The ed- and year- markers are POSITIONAL: the edition
      # attaches to the component it follows (the base when no component
      # precedes it), and a year belongs to a component only when it
      # follows that component's own edition — the separately-published
      # mode; otherwise it is the base with-year qualifier.
      def consume_marker!(segment, attrs, segments, ctx, urn)
        marker, value = MARKER_RE.match(segment).captures
        key, pattern = MARKERS.fetch(marker)
        raise_invalid!(marker, value, urn) unless value.match?(pattern)
        assert_spec_parent!(key, ctx, urn)
        return consume_positional!(attrs, key, value, ctx, urn) if
          POSITIONAL_MARKERS.include?(key)

        # The hyphen-joined compound appendix value ("D-2", the MRN
        # emission) splits into the appendix and its subnumber; the
        # legacy emission instead carries the subnumber as the bare
        # atom consumed below.
        if key == :appendix && (compound = /\A([A-Z])-(\d+)\z/.match(value))
          store!(attrs, :appendix, compound[1], urn)
          store!(attrs, :appendix_subnumber, compound[2], urn)
        else
          store!(attrs, key, value, urn)
        end
        ctx[:component] = key
        ctx[:edition_owner] = nil
        consume_subnumber!(attrs, key, segments, ctx, urn)
      end

      # specsub-/specvar- are children of the spec atom — allowed only
      # in their parent's slot (the MRN_SEGMENTS table in the generator).
      def assert_spec_parent!(key, ctx, urn)
        return unless %i[spec_sub spec_variant].include?(key)
        return if SPEC_PARENTS.include?(ctx[:component])

        raise Pubid::Errors::UrnParseError,
              "#{key}- is only allowed after spec- in #{urn.inspect}"
      end

      def raise_invalid!(marker, value, urn)
        raise Pubid::Errors::UrnParseError,
              "Invalid #{marker} value #{value.inspect} in #{urn.inspect}"
      end

      # ed- and year- are POSITIONAL markers (see the marker docs): the
      # edition attaches to the component it follows, the year to the
      # edition owner. An S-4 spec carries neither — it rides its
      # publication's edition.
      def consume_positional!(attrs, key, value, ctx, urn)
        if SPEC_NODES.include?(ctx[:component])
          raise Pubid::Errors::UrnParseError,
                "an S-4 spec rides its publication's edition: #{key}- " \
                "cannot follow a spec segment in #{urn.inspect}"
        end

        if key == :edition
          return store_component_scoped!(attrs, :edition, value, ctx, urn)
        end

        store_year!(attrs, value, ctx, urn)
      end

      def store_component_scoped!(attrs, stem, value, ctx, urn)
        owner = ctx[:component]
        store!(attrs, owner ? :"#{owner}_#{stem}" : stem, value, urn)
        ctx[:edition_owner] = owner
      end

      def store_year!(attrs, value, ctx, urn)
        owner = ctx[:edition_owner]
        attrs_key = owner && owner != :base ? :"#{owner}_year" : :year
        ctx[:edition_owner] = nil
        store!(attrs, attrs_key, value, urn)
      end

      def consume_subnumber!(attrs, key, segments, ctx, urn)
        return unless key == :appendix && segments.first&.match?(SUBNUMBER_RE)

        store!(attrs, :appendix_subnumber, segments.shift, urn)
      end

      # Legacy dotted-key decode. The legacy appendix value stored the
      # subnumber inside one string ("appendix.D-2"); it decodes into the
      # two components.
      def consume_legacy!(segment, attrs, urn)
        match = LEGACY_RE.match(segment)
        key = LEGACY_KEYS.fetch(match[1]) do
          raise Pubid::Errors::UrnParseError,
                "Unexpected segment #{segment.inspect} in #{urn.inspect}"
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
