# frozen_string_literal: true

module Pubid
  module Ashrae
    # Parser class for ASHRAE identifiers
    # Single Responsibility: Parsing ASHRAE identifier syntax
    class Parser
      # Pre-parse ingestion normalizations (R2): every parse path feeds
      # the grammar the same normalized string.
      def self.normalize_input(string)
        # Strip leading/trailing whitespace
        cleaned = string.strip

        # Handle fixture format: !original!canonical
        # Extract just the original identifier for parsing
        if cleaned.start_with?("!")
          parts = cleaned.split("!")
          # Format: "" (before first !) + "original" + "canonical"
          cleaned = parts[1] if parts.size >= 3
        end

        # Normalize multiple spaces to single space
        cleaned = cleaned.gsub(/\s+/, " ")

        # Normalize reaffirmation patterns
        cleaned = cleaned.gsub(/\(RA\s+(\d{4})\)/, "(RA \\1)")
        cleaned = cleaned.gsub(/RA\s+(\d{4})/, "RA \\1")

        # Remove trailing periods and commas
        cleaned = cleaned.gsub(/[,.]$/, "")

        # Remove trailing double parentheses (typos in source data)
        cleaned = cleaned.gsub("))", ")")

        # Fix unclosed trailing parenthesis (data truncation issue)
        open_count = cleaned.count("(")
        close_count = cleaned.count(")")
        if open_count > close_count
          cleaned += ")" * (open_count - close_count)
        end

        # Normalize dash patterns (remove space around dash in year/code)
        cleaned = cleaned.gsub(/-\s+/, "-")
        cleaned = cleaned.gsub(/\s+/, " ") # Clean up any double spaces created

        # Preprocess ", and" and " and" patterns in addenda code lists
        # This fixes greedy matching where "and" gets consumed as a code
        # Only replace "and" in code lists (between Addendum/Addenda and to/for/(end)
        # NOT in descriptive text that follows
        if cleaned =~ /\bAddenda\s+/ || cleaned =~ /\bAddendum\s+/
          # Find the boundary where code list ends (to, for, or opening paren)
          boundary_pattern = /\s+(?:to|for|\()/
          boundary_match = cleaned.match(boundary_pattern)

          if boundary_match
            # Only replace "and" in the portion before the boundary
            boundary_pos = cleaned.index(boundary_match[0])
            before_boundary = cleaned[0...boundary_pos]
            after_boundary = cleaned[boundary_pos..]

            # Replace ", and" and " and" in the code list portion only
            before_boundary = before_boundary.gsub(/,\s+and\s+/i, ", ")
            before_boundary = before_boundary.gsub(/\s+and\s+/i, ", ")

            cleaned = before_boundary + after_boundary
          else
            # No boundary found, apply to entire string
            cleaned = cleaned.gsub(/,\s+and\s+/i, ", ")
            cleaned = cleaned.gsub(/\s+and\s+/i, ", ")
          end

          # Normalize "Addendum" to "Addenda" when followed by multiple codes (comma-separated)
          # Pattern: "Addendum a, b" -> "Addenda a, b"
          cleaned = cleaned.gsub(/\bAddendum\s+([a-z]+)\s*,\s*/i,
                                 "Addenda \\1, ")
        end

        cleaned
      end
    end
  end
end
