# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Components
    # Publication date component
    class Date < Lutaml::Model::Serializable
      attribute :year, :string
      attribute :month, :string
      attribute :day, :string

      # Render date with optional context for flavor-specific formatting
      #
      # @param _context [RenderingContext] rendering context
      #   (for future extensibility)
      # @param _include_month [Boolean] include month in output
      #   (for future extensibility)
      # @return [String] rendered date string
      def to_s(_context: nil, _include_month: false)
        return year.to_s unless month

        result = "#{year}-#{month}"
        result += "-#{day}" if day
        result
      end

      # Returns hash code for date component
      # @return [Integer] hash code
      # @note Memoized for performance
      def hash
        @hash ||= [year, month, day].compact.map(&:hash).hash
      end

      # Checks equality with another date component
      # @param other [Object] object to compare with
      # @return [Boolean] true if equal
      def eql?(other)
        return false unless other.is_a?(self.class)

        year == other.year && month == other.month && day == other.day
      end
    end
  end
end
