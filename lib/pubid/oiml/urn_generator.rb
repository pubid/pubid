# frozen_string_literal: true

module Pubid
  module Oiml
    # Generates RFC 5141-bis compliant URNs from OIML identifiers
    #
    # URN format: urn:oiml:{type}:{number}:{year}:{stage}:{iteration}:{language}
    # Example: urn:oiml:r:111-1:2004:d1:en for "OIML R 111-1 (2004) D1"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "oiml"]

        # Type (R, D, etc.)
        if identifier.respond_to?(:type) && identifier.type
          parts << identifier.type.to_s.downcase
        else
          parts << "r"
        end

        # Code (may include series and number)
        if identifier.respond_to?(:code) && identifier.code
          parts << identifier.code.to_s
        end

        # Date (year)
        if identifier.respond_to?(:date) && identifier.date
          year = identifier.date.respond_to?(:year) ? identifier.date.year : identifier.date.to_i
          parts << year.to_s
        elsif identifier.respond_to?(:year) && identifier.year
          parts << identifier.year.to_s
        end

        # Draft stage (D, F, CD, CDV, etc.)
        if identifier.respond_to?(:stage) && identifier.stage
          parts << identifier.stage.to_s.downcase
        end

        # Draft iteration
        if identifier.respond_to?(:iteration) && identifier.iteration
          parts << identifier.iteration.to_s
        end

        # Language
        if identifier.respond_to?(:language) && identifier.language
          parts << identifier.language.to_s.downcase
        end

        # Publisher
        if identifier.respond_to?(:publisher) && identifier.publisher
          pub = identifier.publisher.to_s.downcase
          parts[1] = pub
        end

        # For supplements
        if identifier.is_a?(SupplementIdentifier)
          # Add supplement type (amd, cor)
          if identifier.respond_to?(:typed_stage) && identifier.typed_stage
            supp_type = identifier.typed_stage.type_code.to_s
            parts << supp_type if supp_type
          end

          # Add supplement number
          if identifier.respond_to?(:number) && identifier.number
            number = identifier.number.respond_to?(:value) ? identifier.number.value : identifier.number.to_s
            parts << number
          end
        end

        parts.join(":")
      end
    end
  end
end
