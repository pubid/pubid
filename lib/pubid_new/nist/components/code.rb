# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # Code component for NIST identifiers
      # Handles number codes like series, volume, etc.
      class Code < Lutaml::Model::Serializable
        attribute :number, :string
        attribute :subpart, :string

        def to_s
          result = number.to_s
          result += ".#{subpart}" if subpart
          result
        end

        # Alias for compatibility
        def value
          to_s
        end

        # Backward compatibility: extract part from compound numbers like "140-2"
        # Returns the part number if the value contains a dash, nil otherwise
        def part
          return nil unless number && number.include?('-')
          # Split by last dash to handle patterns like "4-4" (just number-part)
          # and "4-M-5" (which would return "M-5" as part)
          parts = number.to_s.split('-')
          parts.last if parts.length > 1
        end
      end
    end
  end
end
