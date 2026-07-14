# frozen_string_literal: true

module Pubid
  module Gost
    # Generates URN strings for GOST identifiers.
    #
    # Format:
    #   urn:gost:std:<number>[:<year>]              (interstate)
    #   urn:gost:std:r:<number>[:<year>]            (Russian national)
    #   urn:gost:std:r:<number>[:<year>]            (IdenticalAdoption delegates to base)
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        return generate_for_base(identifier.base) if identifier.is_a?(Identifiers::IdenticalAdoption)
        return generate_for_base(identifier) if standard?(identifier)

        raise ArgumentError,
              "Unknown GOST identifier class: #{identifier.class}"
      end

      private

      def generate_for_base(id)
        parts = ["urn:gost:std"]
        parts << "r" if id.is_a?(Identifiers::NationalStandard)
        parts << id.number.to_s
        parts << id.year.to_s if id.year
        parts.join(":")
      end

      def standard?(id)
        id.is_a?(Identifiers::InterstateStandard) ||
          id.is_a?(Identifiers::NationalStandard)
      end
    end
  end
end
