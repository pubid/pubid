# frozen_string_literal: true

module Pubid
  module Utils
    # String normalization utilities for PubID parsing and rendering
    #
    # This module provides centralized string manipulation methods
    # to reduce duplication and improve consistency.
    #
    # == Usage
    #
    #   Pubid::Utils::StringNormalizer.normalize_dashes(str)
    #   Pubid::Utils::StringNormalizer.normalize_whitespace(str)
    #   Pubid::Utils::StringNormalizer.split_compound_number(str)
    #
    class StringNormalizer
      # Unicode dash characters that should be normalized to ASCII hyphen
      DASH_CHARS = ["-", "‑", "‐", "–", "—"].freeze

      # Whitespace characters to normalize to single space
      WHITESPACE_CHARS = [" ", "\t", "\n", "\r", "\u00A0"].freeze

      class << self
        # Normalize all dash characters to ASCII hyphen
        #
        # @param str [String, nil] input string
        # @return [String] normalized string with ASCII hyphens
        #
        # @example Normalize unicode dashes
        #   StringNormalizer.normalize_dashes("ISO‑9001") # => "ISO-9001"
        #   StringNormalizer.normalize_dashes("ISO–9001") # => "ISO-9001"
        #
        def normalize_dashes(str)
          return str if str.nil?

          str.tr(DASH_CHARS.join, "-")
        end

        # Normalize whitespace to single space and strip
        #
        # @param str [String, nil] input string
        # @return [String] normalized string with single spaces
        #
        # @example Normalize whitespace
        #   StringNormalizer.normalize_whitespace("ISO  9001") # => "ISO 9001"
        #   StringNormalizer.normalize_whitespace("ISO\t9001") # => "ISO 9001"
        #
        def normalize_whitespace(str)
          return "" if str.nil?

          str.gsub(/[#{WHITESPACE_CHARS.join}]+/, " ").strip
        end

        # Clean and uppercase abbreviation
        #
        # @param str [String, nil] input string
        # @return [String] cleaned and uppercased abbreviation
        #
        # @example Clean abbreviation
        #   StringNormalizer.clean_abbr("  amd  ") # => "AMD"
        #   StringNormalizer.clean_abbr("Amd") # => "AMD"
        #
        def clean_abbr(str)
          return "" if str.nil?

          normalize_whitespace(str).upcase
        end

        # Split compound number (e.g., "800-53-1" -> ["800", "53", "1"])
        #
        # @param str [String] input string
        # @param separators [Array<String>] separators to split on
        # @return [Array<String>] split parts
        #
        # @example Split compound numbers
        #   StringNormalizer.split_compound_number("800-53-1")
        #   # => ["800", "53", "1"]
        #   StringNormalizer.split_compound_number("800/53")
        #   # => ["800", "53"]
        #
        def split_compound_number(str, separators: ["-", "/"])
          return [] unless str

          normalized = normalize_dashes(str)
          normalized.split(/[#{separators.join}]/).reject(&:empty?)
        end

        # Extract numeric suffix from string
        #
        # @param str [String] input string
        # @return [Array<String, nil>] [number, suffix] or [nil, nil]
        #
        # @example Extract number and suffix
        #   StringNormalizer.extract_number_suffix("800-53r5") # => ["53", "r5"]
        #   StringNormalizer.extract_number_suffix("ISO") # => [nil, nil]
        #
        def extract_number_suffix(str)
          return [nil, nil] unless str

          match = str.match(/^(\D+)?(\d+)([a-zA-Z]+)?$/)
          return [nil, nil] unless match

          number = match[2]
          suffix = match[3]
          [number, suffix]
        end

        # Join parts with proper separator, skipping nils
        #
        # @param parts [Array] parts to join
        # @param separator [String] separator between parts
        # @return [String] joined string
        #
        # @example Join parts
        #   StringNormalizer.join_parts(["ISO", "9001", nil, "2015"], " ")
        #   # => "ISO 9001 2015"
        #   StringNormalizer.join_parts(["ISO", nil, "9001"], "-")
        #   # => "ISO-9001"
        #
        def join_parts(parts, separator: "")
          parts.compact.join(separator)
        end

        # Truncate string to max length with ellipsis
        #
        # @param str [String] input string
        # @param max_length [Integer] maximum length
        # @param ellipsis [String] ellipsis string (default: "...")
        # @return [String] truncated string
        #
        # @example Truncate string
        #   StringNormalizer.truncate("International Standard", 15)
        #   # => "International ..."
        #   StringNormalizer.truncate("ISO", 10)
        #   # => "ISO"
        #
        def truncate(str, max_length:, ellipsis: "...")
          return str if str.nil? || str.length <= max_length

          str[0...(max_length - ellipsis.length)] + ellipsis
        end

        # Convert to title case (first letter of each word uppercase)
        #
        # @param str [String] input string
        # @return [String] title cased string
        #
        # @example Title case
        #   StringNormalizer.title_case("international standard")
        #   # => "International Standard"
        #   StringNormalizer.title_case("ISO/TR")
        #   # => "ISO/TR"  # Preserves existing caps
        #
        def title_case(str)
          return "" if str.nil?

          str.split.map do |word|
            if word.upcase == word # Preserve acronyms
              word
            else
              word.capitalize
            end
          end.join(" ")
        end

        # Check if string is blank (nil, empty, or only whitespace)
        #
        # @param str [String] input string
        # @return [Boolean] true if blank
        #
        # @example Check blank
        #   StringNormalizer.blank?(nil) # => true
        #   StringNormalizer.blank?("") # => true
        #   StringNormalizer.blank?("  ") # => true
        #   StringNormalizer.blank?("ISO") # => false
        #
        def blank?(str)
          str.nil? || str.to_s.strip.empty?
        end

        # Safe to_s method that handles nil
        #
        # @param str [String, nil] input string
        # @return [String] string or empty string
        #
        # @example Safe to_s
        #   StringNormalizer.to_s(nil) # => ""
        #   StringNormalizer.to_s("ISO") # => "ISO"
        #
        def to_s(str)
          str.nil? ? "" : str.to_s
        end
      end
    end
  end
end
