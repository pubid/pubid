# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      # IsoDualPublished represents ASTM standards that are dual-published with ISO
      #
      # SEMANTIC NOTE: ISO/ASTM dual-published standards (typically 5xxxx series)
      # - ASTM version: ASTM 52303-24e1 (e1 = edition 1, not "E" prefix)
      # - ISO version: ISO/ASTM 52303:2024
      # 
      # Distinguishing feature: Starts with digit (typically 5xxxx series)
      # These are ASTM's version of standards jointly developed with ISO
      class IsoDualPublished < Standard
        # Inherits all behavior from Standard:
        # - sub_year (a, b, c)
        # - reapproval ((2023))
        # - editorial (e1)
        # - code (number without letter prefix)
        # - year (2024 → 24)
        
        # No additional attributes needed - same structure as Standard
        # The semantic difference is the classification itself
        
        # Rendering is identical to Standard
        # Example: ASTM 52303-24e1
      end
    end
  end
end