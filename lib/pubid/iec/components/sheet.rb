require "lutaml/model"
# frozen_string_literal: true

module Pubid
  module Iec
    module Components
      # Sheet component for IEC sheet notation
      # Single Responsibility: Represents sheet number in IEC identifiers
      # Example: IEC 60695-2-1/1:1994 (where /1 is the sheet)
      class Sheet < Lutaml::Model::Serializable
        attribute :number, :string

        def to_s
          "/#{number}"
        end

        # Parse sheet notation from string like "/1" or "1"
        def self.parse(string)
          number = string.to_s.gsub("/", "")
          new(number: number)
        end

        # Check if sheet number is valid (should be numeric)
        def validate!
          unless number.to_s.match?(/^\d+$/)
            raise ArgumentError, "Sheet number must be numeric: #{number}"
          end
        end
      end
    end
  end
end
