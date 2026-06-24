# frozen_string_literal: true

module Pubid
  module Iso
    module Components
      # Code component for ISO identifiers.
      #
      # Inherits +value+ and +parts+ from the shared Code; overrides
      # rendering to join parts with "-" (ISO convention). Equality and
      # hash are inherited from the shared Code (compare all fields).
      class Code < ::Pubid::Components::Code
        def to_s
          result = value.to_s
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result
        end

        def render(context: nil)
          to_s
        end
      end
    end
  end
end
