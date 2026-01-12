# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NIST Handbook (HB)
      # Examples:
      # - "NIST HB 130" = Handbook 130
      # - "NBS HB 133" = NBS Handbook 133
      class Handbook < Base
        def series_code
          "HB"
        end
      end
    end
  end
end
