# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Itu
    module Identifiers
      # ITU Recommendation
      # Format: ITU-{SECTOR} {SERIES}.{NUMBER}[-PART]
      # Example: ITU-R V.1234-1
      class Recommendation < Base
        # Type-specific rendering handled by Base
      end
    end
  end
end
