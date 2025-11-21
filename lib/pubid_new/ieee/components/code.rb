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
        attribute :parts, :string, collection: true  # Array of part strings

        def initialize(prefix: nil, number: nil, parts: nil)
          super()
          self.prefix = prefix
          self.number = number
          self.parts = parts || []
        end

        # Parse code string into components
        def self.parse(code_str)
          return nil if code_str.nil? || code_str.empty?

          # Extract prefix if present (C, P)
          prefix_match = code_str.match(/^([A-Z])/)
          prefix = prefix_match ? prefix_match[1] : nil

          # Remove prefix for number parsing
          remainder = prefix ? code_str[prefix.length..] : code_str

          # Split by dots or dashes to get number and parts
          components = remainder.split(/[.\-]/)
          number = components.shift

          new(
            prefix: prefix,
            number: number,
            parts: components.empty? ? nil : components
          )
        end

        def to_s
          result = ""
          result += prefix if prefix
          result += number

          if parts && !parts.empty?
            # Use first character after number to determine separator
            # If all parts are numeric, use dot; otherwise use dash
            separator = parts.all? { |p| p.match?(/^\d+$/) } ? "." : "-"
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