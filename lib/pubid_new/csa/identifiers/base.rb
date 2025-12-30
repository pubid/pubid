# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Csa
    module Identifiers
      class Base < SingleIdentifier
        def to_s
          prefix = publisher_prefix || "CSA"

          # Handle code_only identifiers (empty string means no prefix)
          if prefix == ""
            # No prefix for code_only identifiers
            parts = []
          else
            # Determine if we need space after prefix
            # CAN/CSA- and CAN3- end with dash, so no space needed
            needs_space = !prefix.end_with?("-")

            parts = []
            parts << prefix
          end

          # Code and year together
          code_part = code.to_s if code

          # NO. keyword
          if no_number
            code_part += " NO. #{no_number}"
          end

          # Series prefix and keyword (before year)
          if series_prefix
            code_part += " #{series_prefix} SERIES"
          elsif series
            # SERIES without prefix
            code_part += " SERIES"
          end

          parts << code_part if code_part

          # Year with proper format (colon or dash)
          if year
            # Use dash if year_format is dash, otherwise colon
            separator = (year_format == "dash") ? "-" : ":"
            year_part = separator
            year_part += year_prefix if year_prefix  # Add M or F prefix
            year_part += "F" if french && year_format != "dash" && !year_prefix  # Only add F if no prefix
            # Convert 4-digit year back to 2-digit
            year_str = year.to_s
            if year_str.length == 4 && year_str.start_with?("20")
              year_part += year_str[2..3]
            else
              year_part += year_str
            end
            parts[-1] += year_part
          end

          result = if prefix == ""
                     # No prefix, just join parts
                     parts.join(" ")
                   elsif needs_space
                     parts.join(" ")
                   else
                     # No space after dash-ending prefix
                     parts[0] + parts[1..-1].join(" ")
                   end

          # Reaffirmation
          if reaffirmation
            result += " (R#{reaffirmation})"
          end

          # Package (already has leading space from parser)
          if package
            result += package
          end

          result
        end
      end
    end
  end
end