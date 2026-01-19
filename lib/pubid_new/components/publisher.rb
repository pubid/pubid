# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Components
    # Publisher ISO, IEC, etc.
    class Publisher < Lutaml::Model::Serializable
      attribute :body, :string

      def to_s
        body
      end

      # Returns hash code for publisher component
      # @return [Integer] hash code
      # @note Memoized for performance
      def hash
        @hash ||= body.hash
      end

      # Checks equality with another publisher component
      # @param other [Object] object to compare with
      # @return [Boolean] true if equal
      def eql?(other)
        return false unless other.is_a?(self.class)

        body == other.body
      end
    end
  end
end
