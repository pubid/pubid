# frozen_string_literal: true

module Pubid
  module Sae
    class UrnGenerator < Pubid::UrnGenerator::Base
      def urn_type
        return "std" unless identifier.type

        identifier.type.abbr.to_s.downcase
      end

      def urn_year
        return identifier.date.render(context: URN_CONTEXT) if identifier.date&.present?
        return identifier.year&.to_s if maybe(:year)

        nil
      end

      def urn_number
        return nil unless identifier.number

        identifier.number.render(context: URN_CONTEXT)
      end

      def generate
        parts = ["urn", "sae"]
        parts << urn_type
        parts << urn_number if urn_number
        parts << urn_year if urn_year

        parts[1] = urn_publisher if urn_publisher

        parts.join(":")
      end
    end
  end
end
