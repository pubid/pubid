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
          # Handle v#n# format (e.g., v6n1 for Volume 6, Number 1)
          if volume && issue_number
            "NBS CSM v#{volume}#{issue_number.to_s(:short)}"
          # Handle simple number format
          elsif number
            "NBS CSM #{number}"
          # Fallback
          else
            "NBS CSM"
          end
        end
      end
    end
  end
end