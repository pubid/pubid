# frozen_string_literal: true

module Pubid
  module Nist
    module Components
      # Code component for NIST identifiers.
      #
      # Inherits +value+ and +subpart+ from the shared Code; overrides
      # rendering to compose compound numbers like "1234.5" (subpart
      # joined with "." per NIST convention).
      class Code < ::Pubid::Components::Code
        def to_s
          result = value.to_s
          result += ".#{subpart}" if subpart
          result
        end

        def part
          return nil unless value&.include?("-")

          parts = value.to_s.split("-")
          parts.last if parts.length > 1
        end
      end
    end
  end
end
