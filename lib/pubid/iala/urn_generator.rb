# frozen_string_literal: true

module Pubid
  module Iala
    # Generates URN strings for IALA identifiers using the Maritime Resource
    # Name (MRN) namespace that IALA prints on its cover pages.
    #
    # Format: urn:mrn:iala:pub:<type-lower><number>[:ed<edition>][:<lang-lower>]
    # Example: urn:mrn:iala:pub:s1070:ed2.0
    #          urn:mrn:iala:pub:r1016:ed2.0:f
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        return generate_annex if identifier.is_a?(Identifiers::Annex)

        parts = ["urn:mrn:iala:pub", code_segment]
        parts << "ed#{identifier.edition}" if identifier.edition
        parts << identifier.language.downcase if identifier.language
        parts.join(":")
      end

      private

      # URN for an Annex: embeds the base's code, then an "annex" segment
      # (with optional letter suffix), then the annex's own edition/lang.
      #   G1045 Annex Ed 1           → urn:mrn:iala:pub:g1045:annex:ed1
      #   G1128 ANNEX A Ed 1.6 (E)    → urn:mrn:iala:pub:g1128:annex-a:ed1.6:e
      def generate_annex
        base = identifier.base_identifier
        parts = ["urn:mrn:iala:pub",
                 "#{base.type_letter.downcase}#{base.number}"]
        annex_seg = identifier.letter ? "annex-#{identifier.letter.downcase}" : "annex"
        parts << annex_seg
        parts << "ed#{identifier.edition}" if identifier.edition
        parts << identifier.language.downcase if identifier.language
        parts.join(":")
      end

      def code_segment
        "#{identifier.type_letter.downcase}#{identifier.number}"
      end
    end
  end
end
