# frozen_string_literal: true

module Pubid
  module Jis
    # Generates RFC 5141-bis compliant URNs from JIS identifiers
    #
    # URN format: urn:jis:{code}:{year}:{language}:{all_parts}
    # Example: urn:jis:A0001:2023:e for "JIS A 0001:2023 (E)"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "jis"]

        # Code (series.number.parts)
        if identifier.respond_to?(:code) && identifier.code
          parts << identifier.code.to_s
        end

        # Year
        if identifier.respond_to?(:year) && identifier.year
          parts << identifier.year.to_s
        end

        # Language (E or J)
        if identifier.respond_to?(:language) && identifier.language
          parts << identifier.language.to_s.downcase
        end

        # All parts flag (規格群)
        if identifier.respond_to?(:all_parts?) && identifier.all_parts?
          parts << "all"
        end

        # For supplements (amendments, explanations)
        # Add supplement notation
        if identifier.is_a?(SupplementIdentifier) && identifier.respond_to?(:supplement_notation)
          parts << identifier.supplement_notation.to_s.downcase
        end

        parts.join(":")
      end
    end
  end
end
