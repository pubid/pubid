# frozen_string_literal: true

module Pubid
  module Oiml
    class UrnGenerator < Pubid::UrnGenerator::Base
      def urn_type
        return "r" unless identifier.type

        identifier.type.to_s.downcase
      end

      def urn_number
        return nil unless identifier.code

        identifier.code.to_s
      end

      def urn_stage
        identifier.stage&.to_s&.downcase
      end

      def urn_iteration
        identifier.iteration&.to_s
      end

      def urn_language
        identifier.language&.to_s&.downcase
      end

      def generate
        parts = ["urn", "oiml"]
        parts << urn_type
        parts << urn_number if urn_number
        parts << urn_year if urn_year
        parts << urn_stage if urn_stage
        parts << urn_iteration if urn_iteration
        parts << urn_language if urn_language

        parts[1] = identifier.publisher.to_s.downcase if identifier.publisher

        if identifier.is_a?(SupplementIdentifier)
          if identifier.typed_stage
            supp_type = identifier.typed_stage.type_code.to_s
            parts << supp_type if supp_type
          end

          if identifier.number
            parts << identifier.number.to_s
          end
        end

        parts.join(":")
      end
    end
  end
end
