# frozen_string_literal: true

module Pubid
  module Sae
    class UrnGenerator < Pubid::UrnGenerator::Base
      def urn_type
        return "std" unless identifier.type
        identifier.type.abbr.to_s.downcase
      end

      def urn_year
        if identifier.date
          return identifier.date.year.to_s if identifier.date.year
        end
        identifier.year.to_s if identifier.year
      end

      def urn_number
        return nil unless identifier.number
        identifier.number.value.to_s
      end

      def generate
        parts = ["urn", "sae"]
        parts << urn_type
        parts << urn_number if urn_number
        parts << urn_year if urn_year

        parts[1] = identifier.publisher.to_s.downcase if identifier.publisher

        parts.join(":")
      end
    end
  end
end
