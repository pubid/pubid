# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Jis
    module Components
      # Represents a JIS code with series letter, number, and optional parts
      # Examples:
      #   A 0001          => series: "A", number: 1, parts: []
      #   B 0060-1        => series: "B", number: 60, parts: [1]
      #   C 61000-3-2     => series: "C", number: 61000, parts: [3, 2]
      #   C 5401-2-001    => series: "C", number: 5401, parts: [2, 1] (with formatting)
      class Code < Lutaml::Model::Serializable
        attribute :series, :string    # Single letter A-Z
        attribute :number, :integer   # Required number
        attribute :parts, :integer, collection: true # Optional multi-level parts

        # Store original string representations for formatting
        attr_accessor :number_string, :part_strings

        def initialize(series:, number:, parts: nil, number_string: nil,
part_strings: nil)
          @series = series
          @number = number
          @parts = parts || []
          @number_string = number_string || format_number(number)
          @part_strings = part_strings || @parts.map(&:to_s)
        end

        # Render as "SERIES NUMBER[-PART[-SUBPART[...]]]"
        def to_s
          result = "#{series} #{number_string}"
          result += part_strings.map { |p| "-#{p}" }.join if part_strings&.any?
          result
        end

        def ==(other)
          return false unless other.is_a?(Code)

          series == other.series &&
            number == other.number &&
            parts == other.parts
        end

        private

        def format_number(num)
          # Preserve leading zeros: pad to 4 digits if less than 1000
          if num < 1000
            num.to_s.rjust(4, "0")
          else
            num.to_s
          end
        end
      end
    end
  end
end
