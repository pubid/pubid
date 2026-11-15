# frozen_string_literal: true

module Pubid
  module Jis
    module Identifiers
      # Amendment identifier type
      # Format: {base}/AMD {number}:{year}
      # Example: JIS A 0001:1999/AMD 1:2000
      # A yearless amendment prints no colon: {base}/AMD {number} (pubid#745).
      class Amendment < SupplementIdentifier
        def supplement_notation
          "AMD #{number}#{year_tail}"
        end
      end
    end
  end
end
