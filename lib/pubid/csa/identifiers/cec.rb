# frozen_string_literal: true

module Pubid
  module Csa
    module Identifiers
      # Canadian Electrical Code (CEC) identifier
      # Pattern: CSA C22.{2,3,4,6} NO. {number}:{year}
      # Examples: CSA C22.2 NO. 286:23, CSA C22.3 NO. 7:20
      #
      # The "NO." indicates a numbered standard within the C22.x series
      # and must be preserved (not normalized) as a semantic component.
      class Cec < SingleIdentifier
        attribute :cec_part, Components::Code      # C22.2, C22.3, C22.4, C22.6
        attribute :no_number, Components::Code     # Number after NO.

        # Combined code attribute for compatibility
        # Returns cec_part + "-" + no_number (e.g., "C22.2-1")
        def code
          return nil unless cec_part && no_number

          @code ||= Components::Code.new(value: "#{cec_part.value}-#{no_number.value}")
        end

        def to_s
          parts = []

          # Publisher prefix (CSA, CAN/CSA-, CAN3-)
          prefix = publisher_prefix || "CSA"

          # Determine if we need space after prefix
          # CAN/CSA- and CAN3- end with dash, so no space needed
          needs_space = !prefix.end_with?("-")

          parts << prefix unless prefix == ""

          # CEC Part (C22.2, C22.3, etc.)
          parts << cec_part.value if cec_part

          # NO. notation - this is the key semantic component
          parts << "NO."

          # Number after NO.
          parts << no_number.value if no_number

          # Determine separator based on prefix ending
          result = if prefix == ""
                     parts.join(" ")
                   elsif needs_space
                     parts.join(" ")
                   elsif parts.length <= 2
                     # No space after dash-ending prefix (CAN/CSA-, CAN3-)
                     # Join first two parts directly, rest with spaces
                     parts.join
                   else
                     parts[0] + parts[1..].join(" ")
                   end

          # Year with proper format (colon or dash)
          if year
            # Use dash if year_format is dash, otherwise colon
            separator = year_format == "dash" ? "-" : ":"
            year_part = separator

            # Convert 4-digit year back to 2-digit for display
            year_str = year.to_s
            display_year = if year_str.length == 4 && year_str.start_with?("20")
                             year_str[2..3]
                           elsif year_str.length == 4 && year_str.start_with?("19")
                             year_str[2..3]
                           else
                             year_str
                           end

            # Add prefix if present
            year_part += if year_prefix
                           year_prefix + display_year
                         elsif french && year_format != "dash"
                           # Only add F if no prefix already set
                           "F#{display_year}"
                         else
                           display_year
                         end

            result += year_part
          end

          # Reaffirmation - preserve original format and determine spacing
          if reaffirmation
            # Check if year was originally 2-digit (original_year_4digit flag)
            year_was_2digit = !original_year_4digit

            # Check if reaffirmation was originally 4-digit (original_reaffirmation_4digit flag)
            reaffirmation_was_4digit = original_reaffirmation_4digit

            # Preserve original reaffirmation format
            # If original was 4-digit, keep as 4-digit
            # If original was 2-digit, convert from 4-digit storage back to 2-digit
            reaffirmation_str = if reaffirmation_was_4digit
                                  # Original was 4-digit, keep as-is
                                  reaffirmation.to_s
                                elsif reaffirmation.to_s.length == 4 && reaffirmation.to_s.start_with?(
                                  "19", "20"
                                )
                                  # Original was 2-digit, convert 4-digit storage back to 2-digit
                                  # (R2004) → (R04), (R1994) → (R94)
                                  reaffirmation.to_s[2..3]
                                else
                                  # Already 2-digit or other format
                                  reaffirmation.to_s
                                end

            # Determine spacing based on original formats
            # Space needed if year is 2-digit and reaffirmation is 4-digit (original format)
            # No space if both year and reaffirmation are 2-digit, or both are 4-digit
            if year_was_2digit && reaffirmation_was_4digit
              # Year was 2-digit, reaffirmation was 4-digit → add space
              result += " (R#{reaffirmation_str})"
            else
              # Both 2-digit, both 4-digit, or other cases → no space
              result += "(R#{reaffirmation_str})"
            end
          end

          result
        end
      end
    end
  end
end
