# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Nist
    module Components
      # Code component for NIST identifiers.
      # Inherits +value+ from the shared Pubid::Components::Code and adds a
      # NIST-specific +subpart+ (used to render compound numbers like "1234.5").
      class Code < ::Pubid::Components::Code
        attribute :subpart, :string

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
