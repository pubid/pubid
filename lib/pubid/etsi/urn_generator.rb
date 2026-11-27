# frozen_string_literal: true

module Pubid
  module Etsi
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        if identifier.class.name&.include?("SupplementIdentifier")
          generate_supplement_urn
        else
          generate_base_urn
        end
      end

      protected

      def urn_type_for_base
        return "en" unless identifier.type

        identifier.type.to_s.downcase
      end

      def urn_code
        identifier.code&.to_s
      end

      def urn_version
        identifier.version&.to_s&.downcase
      end

      def urn_date
        return nil unless identifier.date

        date = identifier.date
        if date.month
          # `month` is a zero-padded string ("09"); `%d` reads it through
          # Integer(), which refuses "08"/"09" as octal look-alikes —
          # cast to a decimal integer first.
          "#{date.year}-#{format('%02d', date.month.to_i)}"
        else
          date.year.to_s
        end
      end

      def generate_base_urn
        parts = ["urn", "etsi"]
        parts << urn_type_for_base
        parts << urn_code if urn_code
        parts << urn_version if urn_version
        parts << urn_date if urn_date
        parts.join(":")
      end

      def generate_supplement_urn
        parts = ["urn", "etsi"]

        if identifier.base
          base_gen = self.class.new(identifier.base)
          base_urn = base_gen.generate_base_urn

          base_part = base_urn.sub(/^urn:etsi:/, "")
          base_parts = base_part.split(":")

          parts.concat(base_parts)
        else
          parts << urn_type_for_base if identifier.type
          parts << urn_code if urn_code
          parts << urn_version if urn_version
          parts << urn_date if urn_date
        end

        parts << identifier.supplement_notation.to_s.downcase if identifier.supplement_notation

        parts << identifier.number.to_s if identifier.number

        parts.join(":")
      end
    end
  end
end
