# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Cie
    module Components
      # Code component for CIE identifiers
      # Handles number-part-iteration with style awareness
      class Code < Lutaml::Model::Serializable
        attribute :number, :string        # "013", "170", "198"
        attribute :part, :string          # "1", "2", "3"
        attribute :iteration, :string     # "1" in "006.1"
        attribute :style, :string         # "legacy" or "current"

        def to_s
          result = number

          # Handle part AND iteration together (e.g., "19/2.1")
          if part && iteration
            # Use slash for part, then dot for iteration
            result += "/#{part}.#{iteration}"
          # Handle iteration only (e.g., "006.1", "13.3")
          elsif iteration
            result += ".#{iteration}"
          # Handle part only (separator depends on style)
          elsif part
            # Legacy: slash "/" (e.g., "170/1")
            # Current: dash "-" (e.g., "170-1")
            separator = style == "legacy" ? "/" : "-"
            result += "#{separator}#{part}"
          end

          result
        end

        # Parse code string with style detection
        def self.parse(code_str, style: :current)
          return nil if code_str.nil? || code_str.strip.empty?

          # Detect iteration format (dot separator)
          if code_str.include?(".")
            parts = code_str.split(".")
            new(number: parts[0], iteration: parts[1], style: style)
          # Detect part with separator
          elsif code_str.include?("/")
            parts = code_str.split("/")
            new(number: parts[0], part: parts[1], style: "legacy")
          elsif code_str.include?("-")
            parts = code_str.split("-", 2)  # Limit to 2 parts
            new(number: parts[0], part: parts[1], style: "current")
          # Simple number
          else
            new(number: code_str, style: style)
          end
        end
      end
    end
  end
end
