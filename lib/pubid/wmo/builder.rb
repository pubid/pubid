# frozen_string_literal: true

module Pubid
  module Wmo
    # Builds a WMO identifier object from the artifact's bound map —
    # the flat attribute hash the grammar's bindings block declares
    # (typed at the engine, one key per capture).
    #
    # Each grammar alternative path carries exactly one occurrence of
    # `doc_number` and `edition_value`, so one flat map serves all three
    # types; the builder dispatches on `annex_marker` and `wmomarker`.
    class Builder
      def build(parsed)
        return build_annex(parsed) if parsed[:annex_marker]
        return build_publication(parsed) if parsed[:wmomarker]

        Identifiers::Standard.new(**standard_attrs(parsed))
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      def build_publication(hash)
        Identifiers::Publication.new(**standard_attrs(hash))
      end

      def build_annex(hash)
        base = Identifiers::Standard.new(number: hash[:doc_number])

        attrs = {
          base: base,
          annex_form: hash[:annex_marker],
          letter: hash[:annex_letter],
          edition: hash[:edition_value],
        }.compact

        Identifiers::Annex.new(**attrs)
      end

      def standard_attrs(hash)
        {
          number: hash[:doc_number],
          edition: hash[:edition_value],
        }.compact
      end
    end
  end
end

Pubid::Wmo::Builder.prepend(Pubid::Builder::AllPartsWrap)
