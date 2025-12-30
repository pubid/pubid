# frozen_string_literal: true

require_relative "../single_identifier"
require_relative "../components/code"

module PubidNew
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
                   else
                     # No space after dash-ending prefix (CAN/CSA-, CAN3-)
                     # Join first two parts directly, rest with spaces
                     if parts.length <= 2
                       parts.join("")
                     else
                       parts[0] + parts[1..-1].join(" ")
                     end
                   end

          # Year with proper format (colon or dash)
          if year
            # Use dash if year_format is dash, otherwise colon
            separator = (year_format == "dash") ? "-" : ":"
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
            if year_prefix
              year_part += year_prefix + display_year
            elsif french && year_format != "dash"
              # Only add F if no prefix already set
              year_part += "F" + display_year
            else
              year_part += display_year
            end

            result += year_part
          end

          # Reaffirmation
          if reaffirmation
            result += " (R#{reaffirmation})"
          end

          result
        end
      end
    end
  end
end