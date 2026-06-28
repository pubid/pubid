# frozen_string_literal: true

module Pubid
  module Csa
    module Identifiers
      # Canadian Electrical Code (CEC) identifier
      # Pattern: CSA C22.{2,3,4,6} NO. {number}:{year}
      # Examples: CSA C22.2 NO. 286:23, CSA C22.3 NO. 7:20
      #
      # The "NO." indicates a numbered standard within the C22.x series
      # and must be preserved (not normalized) as a semantic component.
      class Cec < SingleIdentifier
        attribute :cec_part, Components::Code      # C22.2, C22.3, C22.4, C22.6
        attribute :no_number, Components::Code     # Number after NO.

        # Combined code attribute for compatibility
        # Returns cec_part + "-" + no_number (e.g., "C22.2-1")
        def code
          return nil unless cec_part && no_number

          @code ||= Components::Code.new(value: "#{cec_part.value}-#{no_number.value}")
        end
      end
    end
  end
end
