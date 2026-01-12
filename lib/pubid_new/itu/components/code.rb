# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Itu
    module Components
      # ITU Code component
      # Format: NUMBER[.SUBSERIES][-PART]
      # Examples: 1234, 1234.5, 1234-1, 1234.5-2
      class Code < Lutaml::Model::Serializable
        attribute :number, :string
        attribute :subseries, :string
        attribute :parts, :string, collection: true

        def initialize(number:, subseries: nil, parts: nil)
          @number = number
          @subseries = subseries
          @parts = parts || []
        end

        def to_s
          result = number.to_s
          result += ".#{subseries}" if subseries
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result
        end

        def ==(other)
          return false unless other.is_a?(Code)

          number == other.number &&
            subseries == other.subseries &&
            parts == other.parts
        end
      end
    end
  end
end
