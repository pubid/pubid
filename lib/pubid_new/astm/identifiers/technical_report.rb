# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      class TechnicalReport < Base
        def to_s
          # Check if ISO/ASTM format: publisher "ISO/ASTM" without TR letter in code
          if publisher == "ISO/ASTM" && (code.nil? || code.letter.nil?)
            result = "ISO/ASTMTR"
            result += code.number if code&.number
            result += format_suffix if format_suffix
            result
          else
            # Simple TR format
            result = "TR"
            result += code.letter if code&.letter
            result += code.number if code&.number
            result += format_suffix if format_suffix
            result
          end
        end
      end
    end
  end
end
