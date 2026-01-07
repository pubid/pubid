# frozen_string_literal: true

require "lutaml/model"

module PubidNew
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
        # @param notation [String, nil] Optional notation override (for backward compatibility)
        # @return [String] The formatted part representation
        def to_s(notation = nil)
          # If notation explicitly provided, use it (backward compatibility)
          return "#{notation}#{value}" if notation

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
            # Fallback for nil or unknown types
            value
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