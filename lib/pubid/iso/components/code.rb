# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Iso
    module Components
      class Code < ::Pubid::Components::Code
        attribute :number, :string
        attribute :parts, :string, collection: true

        def value
          number || self[:value]
        end

        def render(context: nil)
          result = value.to_s
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result
        end

        def to_s
          result = value.to_s
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result
        end

        def ==(other)
          return false unless other.is_a?(Code)

          value == other.value && parts == other.parts
        end
      end
    end
  end
end
