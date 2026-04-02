# frozen_string_literal: true

module PubidNew
  module Plateau
    # Generates RFC 5141-bis compliant URNs from PLATEAU identifiers
    #
    # URN format: urn:plateau:{type}:{number}:{annex}
    # Example: urn:plateau:tr:01:01 for "PLATEAU Technical Report #01-01"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "plateau"]

        # Type (tr for Technical Report, an for Annex)
        if identifier.respond_to?(:type_string)
          type_str = identifier.type_string.to_s.downcase
          # Convert "Technical Report" to "tr", "Annex" to "an"
          parts << case type_str
                   when "technical report"
                     "tr"
                   when "annex"
                     "an"
                   else
                     type_str
                   end
        end

        # Number
        if identifier.respond_to?(:number) && identifier.number
          parts << format("%02d", identifier.number)
        end

        # Annex
        if identifier.respond_to?(:annex) && identifier.annex
          parts << format("%02d", identifier.annex)
        end

        parts.join(":")
      end
    end
  end
end
