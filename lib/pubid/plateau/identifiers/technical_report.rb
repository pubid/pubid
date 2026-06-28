# frozen_string_literal: true

module Pubid
  module Plateau
    module Identifiers
      # PLATEAU Technical Report
      # Format: PLATEAU Technical Report #NN[-annex]
      # Example: PLATEAU Technical Report #01
      class TechnicalReport < Base
        def type_string
          "Technical Report"
        end
      end
    end
  end
end
