# frozen_string_literal: true

module Pubid
  module Adobe
    # Generates URN strings for Adobe identifiers.
    #
    # Format:
    #   urn:adobe:tech-note:<number>            e.g. urn:adobe:tech-note:5014
    #   urn:adobe:publication:<slug>[:v<ver>]   e.g. urn:adobe:publication:adobe-glyph-list
    #                                             urn:adobe:publication:adobe-japan1:v7
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        if identifier.is_a?(Identifiers::TechNote)
          generate_tech_note
        elsif identifier.is_a?(Identifiers::Publication)
          generate_publication
        else
          raise ArgumentError,
                "Unknown Adobe identifier class: #{identifier.class}"
        end
      end

      private

      def generate_tech_note
        "urn:adobe:tech-note:#{identifier.number}"
      end

      def generate_publication
        parts = ["urn:adobe:publication", identifier.slug]
        parts << "v#{identifier.version}" if identifier.version
        parts.join(":")
      end
    end
  end
end
