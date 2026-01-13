# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NIST Federal Information Processing Standards (FIPS)
      # Examples:
      # - "FIPS 140-3" (no NIST prefix)
      # - "NIST FIPS 140-3" (also accepted, normalizes to FIPS 140-3)
      class FederalInformationProcessingStandards < Base
        def series_code
          "FIPS"
        end

        # FIPS identifiers don't use "NIST" prefix in output
        def default_publisher
          ""  # Empty string, no publisher prefix
        end

        private

        def to_short_style
          # FIPS format: "FIPS 14e1971" (no NIST prefix)
          result = series_code
          result += " #{number.value}" if number
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result += edition.to_s if edition
          result
        end
      end
    end
  end
end
