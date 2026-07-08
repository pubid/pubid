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
        # Bulletin issues carry no code; the (year, issue, sequence) tuple
        # is the locator. URNs are canonical regardless of how the input was
        # formatted, so we always emit the structured YYYY-II-SS form even
        # when the identifier was parsed from a citation string.
        if identifier.is_a?(Identifiers::Bulletin)
          parts = ["urn", "oiml", "bulletin"]
          parts << bulletin_locator if identifier.date&.present?
          parts << urn_language if urn_language
          return parts.join(":")
        end

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

      # Structured locator "YYYY-II-SS" (or "YYYY-II" / "YYYY") for a Bulletin.
      # Built directly from the date year and the issue/sequence attributes so
      # the URN is identical regardless of whether the input was the structured
      # or citation form.
      def bulletin_locator
        locator = identifier.date.year.to_s
        locator += "-#{identifier.issue}" if identifier.issue
        locator += "-#{identifier.sequence}" if identifier.sequence
        locator
      end
    end
  end
end
