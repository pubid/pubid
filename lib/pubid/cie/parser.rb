# frozen_string_literal: true

module Pubid
  module Cie
    # Parser for CIE identifiers
    # Handles dual-style system (legacy vs current)
    class Parser
      # Pre-parse ingestion normalizations (R2): every parse path feeds
      # the grammar the same normalized string.
      def self.normalize_input(string)
        # Minimal preprocessing for data quality
        cleaned = string.strip

        # Remove comments (text after #)
        cleaned = cleaned.gsub(/\s*#.*$/, "")

        # Normalize spaces
        cleaned = cleaned.gsub(/\s+/, " ")

        # Insert missing colon before year in language patterns like /E2007 -> /E:2007
        # This is a data quality fix - correct format always has colon
        cleaned = cleaned.gsub(%r{/(E|F|G|DE|ES|CN|RU|FR)(\d{4})}, '/\1:\2')

        cleaned
      end
    end
  end
end
