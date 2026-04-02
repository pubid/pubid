# frozen_string_literal: true

require "parslet"

module PubidNew
  module Iso
    # Utility methods for ISO identifiers
    module Utilities
      module_function

      # Parse identifier from document title
      #
      # This method attempts to extract an ISO identifier from a document title
      # by progressively removing trailing words until a valid identifier is found.
      #
      # @param title [String] Document title
      # @return [Identifier, nil] Parsed identifier, or nil if not found
      #
      # @example Extract identifier from title
      #   parse_from_title("ISO 9001:2015 Quality management systems")
      #   => #<PubidNew::Iso::Identifiers::InternationalStandard>
      def parse_from_title(title)
        return nil if title.nil? || title.empty?

        # Try to extract from the title by looking for common patterns
        # Pattern 1: Title starts with identifier (e.g., "ISO 9001:2015 - Quality...")
        if match = title.match(/^([A-Z]{2,4}(?:\/[A-Z]{2,4})?\s+\d+(?:-\d+)?(?::\d{4})?(?:\/[A-Z]+\s+\d+(?::\d{4})?)?)/i)
          candidate = match[1]
          begin
            return PubidNew::Iso.parse(candidate)
          rescue Parslet::ParseFailed
            # Continue to next method
          end
        end

        # Pattern 2: Look for identifier within title (e.g., "Document on ISO 9001 requirements")
        # Common ISO identifier pattern: ISO/IEC 1234-1:2015
        identifier_pattern = /
          \b
          (?:ISO|IEC)
          (?:\/[A-Z]{2,4})?  # Optional copublisher
          \s+
          \d+(?:-\d+)?       # Number and optional part
          (?::\d{4})?        # Optional year
          (?:\/[A-Z]+\s+\d+(?::\d{4})?)?  # Optional supplement
          \b
        /ix

        # Scan for matches and try each one
        matches = title.to_enum(:scan, identifier_pattern).map { Regexp.last_match }
        matches.each do |m|
          begin
            return PubidNew::Iso.parse(m[0].strip)
          rescue Parslet::ParseFailed
            # Try next match
          end
        end

        # Pattern 3: Split title into words and try progressively shorter suffixes
        words = title.split(/\s+/)
        (2..[words.length, 8].min).each do |count|
          candidate = words[-count..-1].join(" ")
          begin
            return PubidNew::Iso.parse(candidate)
          rescue Parslet::ParseFailed
            # Try with fewer words
          end
        end

        # Pattern 4: Try removing trailing descriptive text
        # Common patterns: " — Title", " - Title", ": Title"
        title.split(/[\s—::-]+/).reverse.each do |part|
          next if part.nil? || part.length < 5  # Skip very short parts
          begin
            return PubidNew::Iso.parse(part.strip)
          rescue Parslet::ParseFailed
            # Try next part
          end
        end

        nil
      end
    end
  end
end
