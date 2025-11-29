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
      end
    end
  end
end