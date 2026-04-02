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

        # NEW: Handle update attribute (e.g., "Upd12-1926" for supplement patterns)
        if update
          # Check if this is an implicit supplement (no explicit "sup/supp" marker, just update)
          # For implicit supplements like "145r11/1925", don't add "sup" before the update
          is_implicit = respond_to?(:implicit_supplement) && implicit_supplement == true

          if is_implicit
            # Implicit supplement: "{base}/{update}" (e.g., "145/Upd1-192511")
            result += "/#{update}"
          else
            # Explicit supplement: "{base}sup/{update}" (e.g., "118sup/Upd12-1926")
            is_circ_supplement = series.to_s == "LCIRC" || series.to_s == "CIRC"
            result += is_circ_supplement ? "sup" : "supp"
            result += "/#{update}"
          end
          return result
        end

        # Original supplement rendering
        # For LCIRC/CIRC supplements with update, use "sup"
        # For LCIRC/CIRC supplements without update, normalize "sup" to "supp" for consistency
        is_circ_supplement = series.to_s == "LCIRC" || series.to_s == "CIRC"
        # When update is present, use "sup" (e.g., "118sup/Upd1-192612")
        # When update is not present, use "supp" (e.g., "378Gsupp" - normalized from "sup")
        result += if is_circ_supplement && !update
                     "supp"
                   elsif is_circ_supplement
                     "sup"
                   else
                     "supp"
                   end

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
