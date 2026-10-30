# frozen_string_literal: true

module Pubid
  module Api
    class Parser
      # Pre-parse ingestion normalization (R2): every parse path feeds
      # the grammar the same normalized string.
      def self.normalize_input(input)
        # Normalize MPMP typo to MPMS
        input.gsub("API MPMP", "API MPMS")
      end
    end
  end
end
