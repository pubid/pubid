# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Iso
    module Components
      # ISO Publisher with copublisher support
      # Examples: ISO, ISO/IEC, ISO/IEC/IEEE
      class Publisher < Lutaml::Model::Serializable
        attribute :publisher, :string, default: -> { "ISO" }
        attribute :copublisher, :string, collection: true

        # Alias for compatibility with rendering code
        def body
          publisher
        end

        def to_s
          result = publisher
          result += copublisher.map { |cp| "/#{cp}" }.join if copublisher&.any?
          result
        end

        def has_copublisher?
          copublisher&.any?
        end

        def ==(other)
          return false unless other.is_a?(Publisher)

          publisher == other.publisher && copublisher == other.copublisher
        end

        # Returns hash code for publisher component
        # @return [Integer] hash code
        # @note Memoized for performance
        def hash
          @hash ||= [publisher, copublisher].compact.map(&:hash).hash
        end

        # Checks equality using hash for consistency
        # @param other [Object] object to compare with
        # @return [Boolean] true if equal
        def eql?(other)
          hash == other.hash && self == other
        end
      end
    end
  end
end
