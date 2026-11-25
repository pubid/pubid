# frozen_string_literal: true

module Pubid
  module Iala
    # Generates URN strings for IALA identifiers using the Maritime Resource
    # Name (MRN) namespace that IALA prints on its cover pages — the
    # official scheme of IALA Recommendation R1023 (Maritime Resource
    # Names, Ed 1.0, whose own cover prints urn:mrn:iala:pub:r1023:ed1.0)
    # and Guideline G1143 (Unique Identifiers for Maritime Resources):
    # urn:mrn:<org>:<type>:<type-specific-part> with IALA's Organization
    # ID "iala" (G1164) and the publication type "pub" (G1143 Annex A4).
    #
    # Format: urn:mrn:iala:pub:<type-lower><number>[:ed<edition>][:<lang-lower>]
    # Example: urn:mrn:iala:pub:s1070:ed2.0
    #          urn:mrn:iala:pub:r1016:ed2.0:f
    #          urn:mrn:iala:pub:s-201:ed2.0.0  (the S-100-family code face)
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
      #   S-201 ANNEX B2              → urn:mrn:iala:pub:s-201:annex-b2
      def generate_annex
        base = identifier.base
        parts = ["urn:mrn:iala:pub", base_code_segment(base)]
        annex_seg = identifier.letter ? "annex-#{identifier.letter.downcase}" : "annex"
        parts << annex_seg
        parts << "ed#{identifier.edition}" if identifier.edition
        parts << identifier.language.downcase if identifier.language
        parts.join(":")
      end

      def code_segment
        base_code_segment(identifier)
      end

      # The lowercase document identifier in IALA's managed namespace
      # (G1143 §5.1.3: the MRN is case-insensitive, conventionally
      # written lowercase): the legacy series codes join letter and
      # number ("s1070"), the S-100-family codes hyphenate ("s-201").
      def base_code_segment(base)
        if base.is_a?(Identifiers::ProductSpecification)
          "s-#{base.number}"
        else
          "#{base.type_letter.downcase}#{base.number}"
        end
      end
    end
  end
end
