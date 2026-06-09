# frozen_string_literal: true

module Pubid
  module Jis
    module Identifiers
      # Corrigendum identifier type
      # Format: {base}/CORRIGENDUM {number}:{year}
      # Example: JIS B 3700-11:1996/CORRIGENDUM 1:2002
      class Corrigendum < SupplementIdentifier
        def supplement_notation
          "CORRIGENDUM #{number}:#{year_with_reaffirmation}"
        end
      end
    end
  end
end
