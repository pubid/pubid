# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NBS LC (Letter Circular)
      # Examples:
      # - "NBS LC 378" - Basic letter circular
      # - "NBS LCIRC 378g" - With LCIRC variant, letter suffix
      # - "NBS LC 378G" - Letter suffix uppercase
      # - "NBS LC 378sup12/1926" - With supplement date
      # - "NBS LC 378r11/1925" - With revision date
      # - "NBS LC 378(sp)" - With language code
      class LetterCircular < Base
        def default_publisher
          "NBS"
        end

        def series_code
          "LC"
        end
      end
    end
  end
end
