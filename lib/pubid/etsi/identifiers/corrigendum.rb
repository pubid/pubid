# frozen_string_literal: true

module Pubid
  module Etsi
    module Identifiers
      # ETSI Corrigendum
      # Format: {base}/C{number}
      class Corrigendum < SupplementIdentifier
        def supplement_notation
          "C#{number}"
        end
      end
    end
  end
end
