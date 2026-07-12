# frozen_string_literal: true

module Pubid
  module Adobe
    # Builds an Adobe identifier object from the Parslet parse tree.
    class Builder
      def build(parsed)
        return build_tech_note(parsed[:tech_note]) if parsed[:tech_note]
        return build_tech_note_bare(parsed[:tech_note_bare]) if parsed[:tech_note_bare]
        return build_publication_version(parsed[:publication_version]) if parsed[:publication_version]
        return build_publication(parsed[:slug]) if parsed[:slug]

        raise ArgumentError, "Unrecognized Adobe parse tree: #{parsed.inspect}"
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      def build_tech_note(hash)
        Identifiers::TechNote.new(
          number: stringify(hash[:number]),
          slug:   stringify(hash[:slug]),
        )
      end

      def build_tech_note_bare(number_hash)
        Identifiers::TechNote.new(number: stringify(number_hash))
      end

      def build_publication(slug_value)
        Identifiers::Publication.new(slug: stringify(slug_value))
      end

      def build_publication_version(hash)
        Identifiers::Publication.new(
          slug:    stringify(hash[:slug]),
          version: stringify(hash[:version]),
        )
      end

      def stringify(value)
        return nil if value.nil?

        str = value.to_s
        str.empty? ? nil : str
      end
    end
  end
end
