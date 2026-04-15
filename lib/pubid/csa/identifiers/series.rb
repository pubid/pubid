# frozen_string_literal: true

module Pubid
  module Csa
    module Identifiers
      # SeriesIdentifier represents CSA identifiers where SERIES
      # is the primary document type, not just a keyword modifier
      #
      # Examples:
      #   CSA MH SERIES 3.14:20
      #   CSA RV SERIES 1:19
      #   CSA SERIES Z1000:22
      #
      # Difference from Standard with series_keyword:
      #   - Series: SERIES is the document type (primary)
      #   - Standard: SERIES is a modifier keyword (secondary)
      class Series < Base
        # Series prefix (MH, RV, etc.) - optional
        attribute :series_prefix, :string

        def to_s
          result = publisher_prefix_portion

          # Add code FIRST (before SERIES keyword)
          result += code.to_s

          # Add space before series prefix/SERIES keyword
          result += " "

          # Add series prefix if present
          result += "#{series_prefix} " if series_prefix && !series_prefix.empty?

          # Add SERIES keyword
          result += "SERIES"

          # Add year
          result += year_portion

          # Add language
          result += language_portion

          # Add reaffirmation
          result += reaffirmation_portion

          result
        end

        private

        def publisher_prefix_portion
          prefix = publisher_prefix || "CSA"

          # Handle code_only identifiers (empty string means no prefix)
          return "" if prefix == ""

          # Determine if we need space after prefix
          # CAN/CSA- and CAN3- end with dash, so no space needed
          needs_space = !prefix.end_with?("-")

          needs_space ? "#{prefix} " : prefix
        end

        def year_portion
          return "" unless year

          # Use dash if year_format is dash, otherwise colon
          separator = year_format == "dash" ? "-" : ":"
          year_part = separator
          year_part += year_prefix if year_prefix # Add M or F prefix
          year_part += "F" if french && year_format != "dash" && !year_prefix # Only add F if no prefix

          # Convert 4-digit year back to 2-digit
          year_str = year.to_s
          year_part += if year_str.length == 4 && year_str.start_with?("20")
                         year_str[2..3]
                       else
                         year_str
                       end

          year_part
        end

        def language_portion
          "" # CSA doesn't use language codes in rendering
        end

        def reaffirmation_portion
          return "" unless reaffirmation

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
            " (R#{reaffirmation_str})"
          else
            # Both 2-digit, both 4-digit, or other cases → no space
            "(R#{reaffirmation_str})"
          end
        end
      end
    end
  end
end
