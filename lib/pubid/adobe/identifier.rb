# frozen_string_literal: true

module Pubid
  module Adobe
    # Base class for all Adobe identifiers. Canonical name
    # Pubid::Adobe::Identifier; every concrete Adobe identifier
    # (Identifiers::*) descends from it, and Identifiers::Base — aliased
    # at the foot of identifiers/base.rb — points back to it.
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
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse Adobe identifier '#{identifier}': #{e.message}"
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
