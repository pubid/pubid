# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NBS Commercial Standards Monthly Identifier
      # Format: NBS CSM N where N is simple number
      # Example: "NBS CSM 1", "NBS CSM 40"
      class CommercialStandardsMonthly < Base
        def publisher
          "NBS"
        end

        def series
          "CSM"
        end

        def to_s
          # CSM uses part notation: Code already renders number="v6" part="1" as "v6pt1"
          if number
            "NBS CSM #{number.to_s}"
          # Legacy: Handle old volume+issue_number format
          elsif volume && issue_number
            "NBS CSM v#{volume}pt#{issue_number.number}"
          # Fallback
          else
            "NBS CSM"
          end
        end
      end
    end
  end
end