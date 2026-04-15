# frozen_string_literal: true

module Pubid
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
            separator = year_format == "dash" ? "-" : ":"
            year_part = separator
            year_part += year_prefix if year_prefix # Add M or F prefix
            year_part += "F" if french && year_format != "dash" && !year_prefix # Only add F if no prefix
            # Convert 4-digit year back to 2-digit for M/F prefix preservation
            # M1983 → M83, F1983 → F83, 1983 → 83, 20xx → xx
            # However, preserve original 4-digit format if the input was 4-digit (original_year_4digit)
            year_str = year.to_s
            year_part += if original_year_4digit
                           # Preserve 4-digit format (e.g., "M1981" stays "M1981")
                           year_str
                         elsif year_prefix&.match?(/^[MF]$/) && year_str.length == 4 && year_str.start_with?("19")
                           # M/F + 4-digit year (1900s) → convert to 2-digit with prefix
                           year_str[2..3]
                         elsif year_str.length == 4 && year_str.start_with?("20")
                           # 2000s → just last 2 digits
                           year_str[2..3]
                         elsif year_str.length == 4 && year_str.start_with?("19") && !original_year_4digit
                           # 1900s with no M/F prefix, but original was 2-digit (e.g., CAN3-Z299.0-86)
                           # Convert back to 2-digit
                           year_str[2..3]
                         else
                           # Other formats - keep as-is
                           year_str
                         end
            parts[-1] += year_part
          end

          result = if prefix == ""
                     # No prefix, just join parts
                     parts.join(" ")
                   elsif needs_space
                     parts.join(" ")
                   elsif parts.length == 2
                     # No space after dash-ending prefix - join first two parts directly
                     # If there are more parts after code, they should still have spaces
                     parts.join
                   else
                     # More than 2 parts shouldn't happen in current design
                     parts.join
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
