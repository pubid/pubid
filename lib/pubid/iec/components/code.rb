# frozen_string_literal: true

module Pubid
  module Iec
    module Components
      # Code component for IEC identifiers.
      #
      # Inherits +value+ and +prefix+ from the shared Code; overrides
      # rendering to place the prefix (e.g. "TR", "TS") before the value.
      class Code < ::Pubid::Components::Code
        def to_s
          result = ""
          result += "#{prefix} " if prefix
          result += value.to_s
          result
        end

        alias full_code to_s

        # Parse IEC code formats:
        # - "60034" (just number)
        # - "TR 61000" (with prefix)
        # - "TS 62443" (with prefix)
        def self.parse(string)
          parts = string.strip.split(" ", 2)

          if parts.size == 2
            new(prefix: parts[0], value: parts[1])
          else
            new(value: parts[0])
          end
        end
      end
    end
  end
end
