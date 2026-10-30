# frozen_string_literal: true

module Pubid
  module CenCenelec
    class Parser
      # Pre-parse ingestion normalizations (R2): every parse path feeds
      # the grammar the same normalized string.
      def self.normalize_input(input)
        # Normalize special dash characters
        normalized = input.gsub(/[\u2011\u00AD]/, "-")

        # Remove trailing hash symbols
        normalized = normalized.gsub(/#.*$/, "").strip

        # Filter out parenthetical notes (case-insensitive, multiple patterns)
        normalized = normalized.gsub(/\s*\([^)]*corrigendum[^)]*\)/i, "")

        # Normalize dash to slash in publisher combinations
        normalized = normalized.gsub("CEN-CLC", "CEN/CLC")
          .gsub("CLC-CEN", "CLC/CEN")
          .gsub("GUIDE", "Guide")
        normalized
      end
    end
  end
end
