# frozen_string_literal: true

module Pubid
  module Easc
    # Generates URN strings for EASC identifiers.
    #
    # Format:
    #   urn:easc:<series>[:<variant>]:<number>[:<year>]
    #
    # Examples:
    #   urn:easc:pmg:3:2025
    #   urn:easc:pmg:v:31:2001
    #   urn:easc:rmg:151:2025
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        unless identifier.is_a?(Identifiers::Pmg) ||
               identifier.is_a?(Identifiers::Rmg)
          raise ArgumentError,
                "Unknown EASC identifier class: #{identifier.class}"
        end

        parts = ["urn:easc", series_lower]
        parts << variant_lower if identifier.variant
        parts << identifier.number.to_s
        parts << identifier.year.to_s if identifier.year
        parts.join(":")
      end

      private

      def series_lower
        identifier.series.to_s.downcase
      end

      def variant_lower
        identifier.variant.to_s.downcase
      end
    end
  end
end
