# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NIST Federal Information Processing Standards (FIPS)
      # Examples:
      # - "NIST FIPS 140-3" = FIPS 140-3
      # - "NIST FIPS 186-5" = FIPS 186-5
      class FederalInformationProcessingStandards < Base
        def series_code
          "FIPS"
        end
      end
    end
  end
end