# frozen_string_literal: true

module PubidNew
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

          # Add series prefix if present
          result += "#{series_prefix} " if series_prefix && !series_prefix.empty?

          # Add SERIES keyword
          result += "SERIES "

          # Add code
          result += code.to_s

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

          year_part
        end

        def language_portion
          ""  # CSA doesn't use language codes in rendering
        end

        def reaffirmation_portion
          reaffirmation ? " (R#{reaffirmation})" : ""
        end
      end
    end
  end
end