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
        parts = ["urn:mrn:iala:pub", code_segment]
        parts << "ed#{identifier.edition}" if identifier.edition
        parts << identifier.language.downcase if identifier.language
        parts.join(":")
      end

      private

      def code_segment
        "#{identifier.type_letter.downcase}#{identifier.number}"
      end
    end
  end
end
