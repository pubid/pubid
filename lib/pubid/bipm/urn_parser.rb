# frozen_string_literal: true

module Pubid
  module Bipm
    # Inverts {UrnGenerator}, rebuilding the identifier directly from the URN
    # fields (rather than reconstructing a printed string) because the printed
    # forms carry surface detail — meeting ordinals, French wording — that the
    # canonical URN intentionally omits.
    #
    # Two URN generations parse. The canonical face leads with the guide's
    # `v1` version segment (see UrnGenerator for the per-family shapes). The
    # pre-adoption face this flavor emitted for years (`urn:bipm:cipm:res:
    # 101-1:2012`, `urn:bipm:si-brochure:e:9e:v3.01:2019/2024`, …) stays
    # parseable as a documented parse-in alias of the same identity: the
    # landed relaton-data-bipm records and any consumer-stored URN keep
    # resolving while the re-crawl lags. The EMITTER is the new shape; an
    # alias never renders back as itself, it rebuilds the identifier whose
    # `to_urn` is the v1 face.
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = body.split(":", -1)

        if parts.first == "v1"
          parse_canonical(parts.drop(1))
        else
          parse_legacy(parts)
        end
      end

      private

      # The v1 canonical shapes, with the version segment stripped. The
      # brochure family differs structurally (group lead, no language
      # segment, stripped e/v), so it dispatches before the group-leading
      # committee/meeting shape.
      def parse_canonical(parts)
        case parts.first
        when "metrologia" then build_metrologia(parts)
        when "bipm" then build_si_brochure_canonical(parts.drop(2))
        else build_group_leading(parts, canonical_type: true)
        end
      end

      # The legacy landed shapes (no v1 segment), kept as parse-in aliases.
      def parse_legacy(parts)
        case parts.first
        when "metrologia" then build_metrologia(parts)
        when "si-brochure" then build_si_brochure(parts)
        else build_group_leading(parts, canonical_type: false)
        end
      end

      def build_group_leading(parts, canonical_type:)
        group = parts[0].upcase
        if parts[1] == "meeting"
          Identifiers::Meeting.new(
            group: group, number: parts[2].to_s, year: parts[3]&.to_i,
          )
        else
          number, appendix, annex = split_appendix(parts[2])
          Identifiers::CommitteeDocument.new(
            group: group,
            type_code: type_code_from_segment(parts[1],
                                              canonical_type: canonical_type),
            number: (number.empty? ? nil : number), year: parts[3]&.to_i,
            appendix: appendix, annex: annex,
          )
        end
      end

      # The legacy face carried the lowercase type abbreviation ("res"); the
      # v1 face carries the lowercase English type name ("resolution"). Both
      # resolve through TYPE_WORD_TO_CODE, so an empty segment (the bare MRA
      # form) stays a nil type_code on either face.
      def type_code_from_segment(segment, canonical_type:)
        return nil if segment.nil? || segment.empty?

        word = canonical_type ? segment.capitalize : segment.upcase
        Identifier::TYPE_WORD_TO_CODE[word]
      end

      # Inverse of UrnGenerator#committee_number_segment: splits the folded
      # "-a{appendix}[.{annex}]" tail back out of the identifier segment. A
      # bare number is digits and dashes only, so the letter-prefixed tail is
      # unambiguous.
      def split_appendix(segment)
        match = segment.to_s.match(/\A(.+?)-a(\d+)(?:\.(\d+))?\z/)
        return [segment, nil, nil] unless match

        [match[1], match[2], match[3]]
      end

      # `number` is the relaton index key and is derived, not printed, so it has
      # to be set here exactly as `Builder` sets it — a URN-reconstructed
      # identifier must agree with a parsed one attribute for attribute.
      def build_metrologia(parts)
        Identifiers::MetrologiaArticle.new(
          number: presence(parts[1]), issue: parts[2], article: parts[3],
        )
      end

      # Legacy brochure face: `si-brochure:<lang>:<edition>:<version>:<years>`.
      def build_si_brochure(parts)
        Identifiers::SiBrochure.new(
          number: presence(parts[2]), language: parts[1].to_s.upcase,
          edition: presence(parts[2]), version: presence(parts[3]),
          years: presence(parts[4])
        )
      end

      # Canonical brochure face:
      # `bipm:si-brochure:<edition-number>:<version-number>:<year>` — the
      # guide strips the "e" off the edition and the "v" off the version and
      # drops the language segment, so they are restored here; the year
      # segment stores back into `years` verbatim, which makes the emission
      # idempotent ("2024" re-emits "2024"). The legacy face's language and
      # multi-year segments are gone on this face: the guide's URN is
      # language-independent and names the latest year only.
      def build_si_brochure_canonical(parts)
        edition = presence(parts[0])
        edition = "#{edition}e" if edition
        version = presence(parts[1])
        version = "v#{version}" if version
        Identifiers::SiBrochure.new(
          number: edition, edition: edition, version: version,
          years: presence(parts[2])
        )
      end

      # A URN segment that was never filled in is an empty string, not nil.
      def presence(segment)
        segment unless segment.nil? || segment.empty?
      end
    end
  end
end
