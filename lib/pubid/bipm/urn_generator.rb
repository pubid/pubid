# frozen_string_literal: true

module Pubid
  module Bipm
    # Emits a URN carrying the canonical (language/form-neutral) document
    # identity for each family, in the guide-of-record's official shapes
    # (bipm-editor-guides, sources/bipm-references-en.adoc, "URN" clauses):
    #
    #   committee:  urn:bipm:v1:<group>:<type-word>:<identifier>[:<year>]
    #   meeting:    urn:bipm:v1:<group>:meeting:<number>[:<year>]
    #   metrologia: urn:bipm:v1:metrologia:<vol>[:<issue>[:<article>]]
    #   brochure:   urn:bipm:v1:bipm:si-brochure:<edition>:[<version>]:<year>
    #
    # The guide's general pattern is
    # `urn:bipm:{version}:{group}:{venue-type}:{venue-id}
    #  :{type}:{identifier}:{date}` with the venue slots optional. The
    # flavor holds no venue attribute — the venue qualification lives
    # inside the document number itself ("110-17" is the 110th meeting's
    # decision 17) — so the venue slots stay unfilled and one shape per
    # family falls out:
    #
    #   * committee — the guide's `decision` example verbatim:
    #     `urn:bipm:v1:cipm:decision:110-17:2021`. The type segment is the
    #     English type name lowercased (resolution/recommendation/decision/
    #     action/statement), not the REC/RES/DECN abbreviation the previous
    #     face carried; the empty segment stays for the type-less bare MRA
    #     form. The guide's second committee example
    #     (`urn:bipm:v1:cipm:resolution:95-2006:1`) does not fit the stated
    #     pattern — it puts a venue-id (meeting 95, year 2006) and the
    #     outcome ordinal where the pattern's identifier/date slots sit
    #     (its own git history edited it there from `95-2006:resolution:1`,
    #     which DID fit). This flavor emits the pattern-conforming shape;
    #     a venue-qualified number flows through the identifier slot
    #     verbatim.
    #   * meeting — the venue-type `meeting` plus the venue-id, as separate
    #     segments per the guide's meeting-outcomes component list (its only
    #     accepted venue-type value). The guide's proceedings example glues
    #     them (`meeting-26`) and carries a proceedings type + publication
    #     year this flavor does not model.
    #   * metrologia — the guide defines no metrologia URN (its section is
    #     empty), so only the mandatory `v1` convention applies; the series
    #     shape is unchanged.
    #   * brochure — the guide's pattern verbatim: the `bipm` group lead,
    #     the edition without its `e` ("9e" → "9"), the version without its
    #     `v` ("v3.01" → "3.01"), the language segment dropped (the guide's
    #     URN is language-independent) and the year the latest the `years`
    #     range names ("2019/2024" → "2024", the guide's "latest year of
    #     publication at the version"). The version segment stays empty when
    #     absent, per the guide's `urn:bipm:v1:bipm:si-brochure:9::2019`.
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        case identifier
        when Identifiers::CommitteeDocument then committee
        when Identifiers::Meeting then meeting
        when Identifiers::MetrologiaArticle then metrologia
        when Identifiers::SiBrochure then si_brochure
        else
          raise "Cannot build URN for BIPM identifier: #{identifier.class}"
        end
      end

      private

      # The v1 version segment leads every family; the venue-type/venue-id
      # slots of the guide's general pattern stay unfilled because the
      # flavor carries no venue attribute (see the class comment).
      def committee
        id = identifier
        # type_code is nil for the bare MRA form → empty type segment,
        # mirroring the empty-number-segment convention for number-less
        # documents. The segment is the lowercase English type name the
        # guide spells out ("decision"), never the REC/RES/DECN code.
        parts = ["urn", "bipm", "v1", id.group.downcase,
                 committee_type_segment(id), committee_number_segment(id)]
        # A partial (date-less) reference drops the trailing year segment; a
        # number-less-but-dated doc keeps its empty number segment.
        parts << id.year if id.year
        parts.join(":")
      end

      def committee_type_segment(id)
        return "" unless id.type_code

        Identifier::TYPE_NAME_EN[id.type_code].downcase
      end

      # The appendix/annex complement folds into the identifier segment as
      # "-a{appendix}[.{annex}]". A bare number is digits and dashes only, so
      # the letter-prefixed tail is unambiguous on the way back (UrnParser
      # splits it). Built by interpolation, never by appending to
      # `id.number.to_s` — on a String attribute that returns the attribute
      # itself, so a `<<` would mutate the identifier's `number` in place.
      def committee_number_segment(id)
        return id.number.to_s unless id.appendix

        tail = id.annex ? ".#{id.annex}" : ""
        "#{id.number}-a#{id.appendix}#{tail}"
      end

      def meeting
        id = identifier
        parts = ["urn", "bipm", "v1", id.group.downcase, "meeting",
                 id.number.to_s]
        parts << id.year if id.year
        parts.join(":")
      end

      def metrologia
        parts = ["urn", "bipm", "v1", "metrologia", identifier.volume]
        parts << identifier.issue if identifier.issue
        parts << identifier.article if identifier.article
        parts.join(":")
      end

      def si_brochure
        id = identifier
        ["urn", "bipm", "v1", "bipm", "si-brochure",
         brochure_edition_segment(id), id.version.to_s.delete_prefix("v"),
         brochure_year_segment(id)].join(":")
      end

      # The guide's edition-number carries no "e" ("Notice the absence of the
      # letter e after the number"): "9e" emits "9". A variant (Appendix 3 /
      # Concise / FAQ) or a bare section reference names no edition, so the
      # segment is empty — the documented partial-reference bucket.
      def brochure_edition_segment(id)
        id.edition.to_s.delete_suffix("e")
      end

      # The guide's year is "the latest year of publication at the version":
      # the "2019" of "2019", the "2024" of "2019/2024".
      def brochure_year_segment(id)
        id.years.to_s.split("/").last
      end
    end
  end
end
