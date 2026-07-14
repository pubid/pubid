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
        ["urn", "bipm", identifier.group.downcase,
         identifier.type_code.downcase, identifier.number.to_s,
         identifier.year].join(":")
      end

      def meeting
        ["urn", "bipm", identifier.group.downcase, "meeting",
         identifier.number.to_s, identifier.year].join(":")
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
