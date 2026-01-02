# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NIST Technical Note (TN)
      # Examples:
      # - "NIST TN 1234" = Technical Note 1234
      # - "NBS TN 567" = NBS Technical Note 567
      class TechnicalNote < Base
        def series_code
          "TN"
        end

        private

        def to_short_style
          # Call parent implementation
          result = super

          # TN-SPECIFIC: For edition years (not with edition number), use 'e' prefix instead of dash
          # Pattern: "NIST TN 1297-1993" → "NIST TN 1297e1993"
          # But only if edition_year is set and edition is NOT set
          if !edition && edition_year
            # Replace the last occurrence of "-YYYY" with "eYYYY"
            # This handles both "-1993" and "-Feb1985" formats
            result = result.sub(/-(\d{4})$/, 'e\1')
            result = result.sub(/-([A-Za-z]{3,9})(\d{4})$/, 'e\1\2')
          end

          result
        end
      end
    end
  end
end