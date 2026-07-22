# frozen_string_literal: true

module Pubid
  module Nist
    # Base class for NIST supplement identifiers
    # Supplements wrap a base identifier with additional edition information
    #
    # Architecture follows ISO pattern:
    # - base: The base document being supplemented
    # - edition: Edition information for the supplement
    #
    # Examples:
    # - "NBS CIRC 101e2supp" → CircularSupplement(base: "NBS CIRC 101", edition: e2)
    # - "NBS CIRC 25supp-1924" → CircularSupplement(base: "NBS CIRC 25", edition: 1924)
    class SupplementIdentifier < Identifier
      attribute :base, Identifier, polymorphic: true

      # Delegate publisher to base
      def publisher
        base&.publisher
      end

      # Delegate series to base
      def series
        base&.series
      end

      def to_s(format = :short)
        # Handle date range supplements (no base identifier)
        if supplement_date_range_start && supplement_date_range_end
          return "NBS CIRC sup#{supplement_date_range_start}-#{supplement_date_range_end}"
        end

        return super unless base

        result = base.to_s(format)

        # NEW: Handle update attribute (e.g., "Upd12-1926" for supplement patterns)
        if update
          # Implicit supplements (e.g. "145r11/1925") have no explicit marker;
          # everything else uses the canonical single-p "sup" marker
          # (relaton-data-nist uses "sup" across all series).
          is_implicit = self.class.attributes.key?(:implicit_supplement) && implicit_supplement == true
          result += "sup" unless is_implicit
          # Update#to_s emits its own leading separator (/Upd… short, -upd… mr),
          # so append it directly instead of hardcoding the slash.
          result += update.to_s(format)
          return result
        end

        # Canonical supplement marker is single-p "sup" across all NIST/NBS
        # series (relaton-data-nist: SP/CIRC/HB/RPT/LC/IR/MONO/BMS all use "sup").
        result += "sup"

        # Add edition information if present (just ID, not type prefix)
        if edition&.id
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
