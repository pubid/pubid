# frozen_string_literal: true

module Pubid
  module Gost
    # Generates URN strings for GOST identifiers.
    #
    # Format:
    #   urn:gost:std:<number>[:<year>]              (interstate)
    #   urn:gost:std:r:<number>[:<year>]            (Russian national)
    #
    # Examples:
    #   urn:gost:std:14946:82
    #   urn:gost:std:r:34.12:2015
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        raise ArgumentError,
              "Unknown GOST identifier class: #{identifier.class}" \
                unless identifier.is_a?(Identifiers::Standard)

        parts = ["urn:gost:std"]
        parts << "r" if identifier.scope == "russian"
        parts << identifier.number.to_s
        parts << identifier.year.to_s if identifier.year
        parts.join(":")
      end
    end
  end
end
