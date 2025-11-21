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
          "NBS CSM #{number}"
        end
      end
    end
  end
end