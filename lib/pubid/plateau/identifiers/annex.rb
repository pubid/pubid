# frozen_string_literal: true

module Pubid
  module Plateau
    module Identifiers
      # PLATEAU Annex supplement
      # Format: {BASE} Annex {letter}
      # Example: PLATEAU Handbook #00 第1.0版 Annex A
      class Annex < SupplementIdentifier
        def supplement_string
          "Annex #{letter}"
        end
      end
    end
  end
end
