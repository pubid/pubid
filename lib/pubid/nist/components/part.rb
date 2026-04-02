# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Nist
    module Components
      # Part component for NIST publications
      # Format: n{NUMBER}, pt{NUMBER}, or just letter depending on type
      #
      # Type attribute determines rendering:
      #   - "pt" => "pt1" (SP part notation)
      #   - "n" => "n1" (CSM issue notation)
      #   - "" => "A" (letter suffix - just the letter)
      #
      # Examples:
      #   Part.new(type: "pt", value: "1").to_s => "pt1"
      #   Part.new(type: "n", value: "1").to_s => "n1"
      #   Part.new(type: "", value: "A").to_s => "A"
      #
      # Used in:
      #   - CSM: Issue number (n1)
      #   - SP: Part number (pt1)
      #   - Letter suffixes (A, B, C, etc.)
      class Part < Lutaml::Model::Serializable
        attribute :type, :string   # "pt" for part notation, "n" for issue, "" for letter suffix
        attribute :value, :string  # Part number or letter (1, 2, A, B, etc.)

        # Render part with type-specific notation
        # @param notation [Symbol, String, nil] Optional notation override
        #   - :n_notation or "n" → use "n" prefix
        #   - :pt_notation or "pt" → use "pt" prefix
        #   - :letter_notation or "" → just the value (letter suffix)
        # @return [String] The formatted part representation
        def to_s(notation = nil)
          # Handle symbol notation parameters
          notation_to_use = if notation.is_a?(Symbol)
            case notation
            when :n_notation then "n"
            when :pt_notation then "pt"
            when :letter_notation then ""
            else notation.to_s
            end
          else
            notation
          end

          # If notation explicitly provided, use it
          if notation_to_use
            return "#{notation_to_use}#{value}" unless notation_to_use.empty?
            return value
          end

          # Otherwise use type attribute
          case type
          when "pt"
            "pt#{value}"
          when "n"
            "n#{value}"
          when ""
            # Letter suffix - just the letter
            value
          else
            # Fallback for nil or unknown types - default to "n" notation (CSM issue number)
            "n#{value}"
          end
        end

        # Alias for numeric comparison
        def to_i
          value.to_i
        end
      end
    end
  end
end
