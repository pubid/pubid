# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      class TechnicalReport < Base
        def to_s
          # Check if ISO/ASTM format
          if publisher == "ISO/ASTMTR"
            result = "ISO/ASTMTR"
            result += code.number if code
            result += format_suffix if format_suffix
            result
          else
            # Simple TR format without ASTM prefix
            result = ""
            result += "TR"
            result += code.number if code
            result += format_suffix if format_suffix
            result
          end
        end
      end
    end
  end
end