# frozen_string_literal: true

module Pubid
  module Astm
    module Identifiers
      class TechnicalReport < Base
        def to_s
          # Check if ISO/ASTM format: publisher "ISO/ASTM" without TR letter in code
          if publisher == "ISO/ASTM" && (code.nil? || code.letter.nil?)
            result = "ISO/ASTMTR"
          else
            # Simple TR format
            result = "TR"
            result += code.letter if code&.letter
          end
          result += code.number if code&.number
          result += format_suffix if format_suffix
          result
        end
      end
    end
  end
end
