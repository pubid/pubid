# frozen_string_literal: true

module Pubid
  module Idf
    class UrnGenerator < Pubid::UrnGenerator::Base
      def urn_type
        return nil unless identifier.type
        identifier.type.abbr.to_s.downcase
      end

      def urn_number
        return nil unless identifier.number
        identifier.number.value.to_s
      end

      def urn_part
        return nil unless identifier.part
        "-#{identifier.part.value}"
      end

      def urn_subpart
        return nil unless identifier.subpart
        "-#{identifier.subpart.value}"
      end

      def urn_year
        if identifier.date
          return identifier.date.year.to_s if identifier.date.year
        end
        identifier.year.to_s if identifier.year
      end

      def urn_edition
        return nil unless identifier.edition
        num = identifier.edition.number
        return nil unless num
        "ed.#{num}"
      end

      def generate
        parts = ["urn", "idf"]
        parts << urn_number if urn_number
        parts << urn_part if urn_part
        parts << urn_subpart if urn_subpart
        parts << urn_year if urn_year
        parts << urn_edition if urn_edition
        parts << urn_type if urn_type

        if identifier.publisher
          parts[1] = identifier.publisher.body.to_s.downcase
        end

        if identifier.copublishers&.any?
          copubs = identifier.copublishers.map(&:body)
          parts[1] = "#{parts[1]}-#{copubs.join('-').downcase}"
        end

        if identifier.languages&.any?
          parts << identifier.languages.map(&:code).join(",")
        end

        if identifier.is_a?(SupplementIdentifier)
          if identifier.typed_stage
            supp_type = identifier.typed_stage.type_code.to_s
            parts << supp_type if supp_type
          end

          if identifier.number
            parts << identifier.number.value.to_s
          end
        end

        parts.join(":")
      end
    end
  end
end
