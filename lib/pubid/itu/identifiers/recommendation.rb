# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # ITU Recommendation
      # Format: ITU-{SECTOR} {SERIES}.{NUMBER}[-PART]
      # Example: ITU-R V.1234-1
      class Recommendation < Identifier
        # Type-specific rendering handled by Identifier
      end
    end
  end
end
