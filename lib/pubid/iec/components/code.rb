require "lutaml/model"
# frozen_string_literal: true

module Pubid
  module Iec
    module Components
      class Code < Lutaml::Model::Serializable
        attribute :prefix, :string, default: -> {}
        attribute :number, :string
        attribute :part, :string, default: -> {}

        def initialize(value: nil, number: nil, prefix: nil, part: nil)
          # Support both 'value' (for convenience) and 'number' (explicit)
          @number = value || number
          @prefix = prefix
          @part = part
        end

        def to_s
          result = ""
          result += "#{prefix} " if prefix
          result += number
          result += "-#{part}" if part
          result
        end

        def full_code
          to_s
        end

        # Parse IEC code formats:
        # - "60034" (just number)
        # - "60034-1" (number with part)
        # - "TR 61000" (with prefix)
        # - "TS 62443" (with prefix)
        def self.parse(string)
          parts = string.strip.split(" ", 2)

          if parts.size == 2
            # Has prefix: "TR 61000-1-2"
            prefix = parts[0]
            number_part = parts[1]
          else
            # No prefix: "60034-1"
            prefix = nil
            number_part = parts[0]
          end

          # Split number and part
          number_parts = number_part.split("-", 2)
          number = number_parts[0]
          part = number_parts[1]

          new(prefix: prefix, number: number, part: part)
        end
      end
    end
  end
end
