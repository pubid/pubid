# frozen_string_literal: true

module Pubid
  module Adobe
    # Base class for all Adobe identifiers. Canonical name
    # Pubid::Adobe::Identifier; every concrete Adobe identifier
    # (Identifiers::*) descends from it.
    #
    # Adobe identifiers come in two shapes:
    #
    #   * TechNote    — `Adobe Technical Note #<number>` / `ATN<number>`
    #                   e.g. `Adobe Technical Note #5014`, `ATN5014`.
    #   * Publication — slug-keyed named specs that have no number
    #                   e.g. `adobe-glyph-list`, `adobe-japan1-7`.
    class Identifier < ::Pubid::Identifier
      # Parse an Adobe identifier string into an identifier object.
      # @param identifier [String]
      # @return [Pubid::Adobe::Identifier]
      # @raise [Pubid::Errors::ParseError] If parsing fails
      def self.parse(identifier)
        unless identifier.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        # R1 parser swap: the baked PG artifact is the parser of record.
        parsed = Pubid::Pg::Backend.parse(:adobe, identifier.strip)
        Builder.build(parsed)
      end

      attribute :publisher, :string, default: "Adobe"

      ADOBE_TYPE_MAP = {
        "pubid:adobe:tech-note"   => "Pubid::Adobe::Identifiers::TechNote",
        "pubid:adobe:publication" => "Pubid::Adobe::Identifiers::Publication",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: ADOBE_TYPE_MAP
      end

      def to_urn
        UrnGenerator.new(self).generate
      end

      # Short type code (e.g. "ATN", nil for Publication) — convenience
      # accessor used by Renderer and UrnGenerator.
      def type_short
        self.class.type[:short]
      end
    end
  end
end
