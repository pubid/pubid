# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Iso
    module Components
      class Code < ::Pubid::Components::Code
        attribute :parts, :string, collection: true

        def to_s
          result = value.to_s
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result
        end

        def render(context: nil)
          to_s
        end

        def eql?(other)
          return false unless other.is_a?(Code)

          value == other.value && parts == other.parts
        end

        alias == eql?
      end
    end
  end
end
