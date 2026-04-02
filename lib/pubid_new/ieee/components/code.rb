# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Ieee
    module Components
      # IEEE document code (number with parts/subparts)
      # Handles formats like:
      #   802          - simple numbers
      #   802.15.4     - dotted parts
      #   C57.12.00    - prefix with parts
      #   11073-10404  - dashed parts
      class Code < Lutaml::Model::Serializable
        attribute :prefix, :string             # C, P for some identifiers
        attribute :number, :string             # Main number (802, 1234, etc.)
        attribute :parts, :string, collection: true # Array of part strings
        attribute :original_separator, :string # Original separator (. or -) from parsing

        def initialize(prefix: nil, number: nil, parts: nil,
original_separator: nil)
          super()
          self.prefix = prefix
          self.number = number
          self.parts = parts || []
          self.original_separator = original_separator
        end

        # Parse code string into components
        def self.parse(code_str)
          return nil if code_str.nil? || code_str.empty?

          # Extract prefix if present (C, P)
          prefix_match = code_str.match(/^([A-Z])/)
          prefix = prefix_match ? prefix_match[1] : nil

          # Remove prefix for number parsing
          remainder = prefix ? code_str[prefix.length..] : code_str

          # Detect the separator used
          separator = nil
          if remainder.include?(".")
            separator = "."
          elsif remainder.include?("-")
            separator = "-"
          end

          # Split by dots or dashes to get number and parts
          components = remainder.split(/[.\-]/)
          number = components.shift

          new(
            prefix: prefix,
            number: number,
            parts: components.empty? ? nil : components,
            original_separator: separator,
          )
        end

        def to_s
          result = ""
          result += prefix if prefix
          result += number if number  # Guard against nil number (e.g., "ANSI X")

          if parts && !parts.empty?
            # Use original separator if available
            if original_separator
              separator = original_separator
            elsif prefix == "P" || (!prefix && parts.first && parts.first.length > 3)
              # Fallback to heuristics when original separator unknown
              # Determine separator based on prefix and pattern:
              # - Letter prefix (C, etc.) codes use dots: C37.111
              # - P-prefix codes typically use dashes: P11073-10404
              # - Pure numeric codes with 5+ digits use dashes: 61523-4 (IEC style)
              # - Traditional IEEE codes like 802.11 use dots
              #
              # Heuristic:
              # 1. P-prefix or long part (>3 chars) → dash
              # 2. Letter prefix (except P) → dot
              # 3. Long number (5+ digits) → dash (IEC pattern)
              # 4. Default → dot (traditional IEEE)
              separator = "-"
            elsif prefix && prefix != "P"
              separator = "."
            elsif !prefix && number && number.length >= 5
              separator = "-"
            else
              # Default to dot for traditional IEEE codes like 802.11
              separator = "."
            end

            parts.each do |part|
              result += separator + part
            end
          end

          result
        end
      end
    end
  end
end
