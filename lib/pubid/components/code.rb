# frozen_string_literal: true

module Pubid
  module Components
    class Code < Lutaml::Model::Serializable
      attribute :value, :string

      def to_s
        value.to_s
      end

      def render(context: nil)
        value.to_s
      end

      # Returns hash code for code component
      # @return [Integer] hash code
      # @note Memoized for performance
      def hash
        @hash ||= value.hash
      end

      # Checks equality with another code component
      # @param other [Object] object to compare with
      # @return [Boolean] true if equal
      def eql?(other)
        return false unless other.is_a?(self.class)

        value == other.value
      end
    end
  end
end
