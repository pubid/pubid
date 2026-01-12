# frozen_string_literal: true

require_relative "identifiers/base"

module PubidNew
  module Nist
    # Base class for NIST supplement identifiers
    # Supplements wrap a base identifier with additional edition information
    #
    # Architecture follows ISO pattern:
    # - base_identifier: The base document being supplemented
    # - edition: Edition information for the supplement
    #
    # Examples:
    # - "NBS CIRC 101e2supp" → CircularSupplement(base: "NBS CIRC 101", edition: e2)
    # - "NBS CIRC 25supp-1924" → CircularSupplement(base: "NBS CIRC 25", edition: 1924)
    class SupplementIdentifier < Identifiers::Base
      attribute :base_identifier, Identifiers::Base, polymorphic: true

      # Delegate publisher to base_identifier
      def publisher
        base_identifier&.publisher
      end

      # Delegate series to base_identifier
      def series
        base_identifier&.series
      end

      def to_s(format = :short)
        # Handle date range supplements (no base identifier)
        if supplement_date_range_start && supplement_date_range_end
          return "NBS CIRC supp#{supplement_date_range_start}-#{supplement_date_range_end}"
        end

        return super unless base_identifier

        result = base_identifier.to_s(format)
        result += "supp"

        # Add edition information if present (just ID, not type prefix)
        if edition && edition.id
          # Smart dash logic: month=no dash, year=dash
          result += if edition.id.match?(/^[A-Z]/)
                      edition.id
                    else
                      "-#{edition.id}"
                    end
        end

        result
      end
    end
  end
end
