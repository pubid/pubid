# frozen_string_literal: true

module Pubid
  module Bipm
    # Emits a URN carrying the canonical (language/form-neutral) document
    # identity for each family:
    #   committee:  urn:bipm:<group>:<type>:<number>:<year>   (empty number seg
    #                                                          when number-less)
    #   meeting:    urn:bipm:<group>:meeting:<number>:<year>
    #   metrologia: urn:bipm:metrologia:<vol>[:<issue>[:<article>]]
    #   brochure:   urn:bipm:si-brochure:<lang>:<edition>:<version>:<years>
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

      def committee
        id = identifier
        # type_code is nil for the bare MRA form → empty type segment, mirroring
        # the empty-number-segment convention for number-less documents.
        parts = ["urn", "bipm", id.group.downcase,
                 id.type_code.to_s.downcase, committee_number_segment(id)]
        # A partial (date-less) reference drops the trailing year segment; a
        # number-less-but-dated doc keeps its empty number segment.
        parts << id.year if id.year
        parts.join(":")
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
        parts = ["urn", "bipm", id.group.downcase, "meeting", id.number.to_s]
        parts << id.year if id.year
        parts.join(":")
      end

      def metrologia
        parts = ["urn", "bipm", "metrologia", identifier.volume]
        parts << identifier.issue if identifier.issue
        parts << identifier.article if identifier.article
        parts.join(":")
      end

      def si_brochure
        ["urn", "bipm", "si-brochure", identifier.language.to_s.downcase,
         identifier.edition, identifier.version, identifier.years].join(":")
      end
    end
  end
end
