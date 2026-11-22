# frozen_string_literal: true

module Pubid
  module Wmo
    # Builds a WMO identifier object from the artifact's bound map —
    # the flat attribute hash the grammar's bindings block declares
    # (typed at the engine, one key per capture).
    #
    # Each grammar alternative path carries at most one occurrence of
    # `doc_number` and `edition_value`, so one flat map serves all three
    # types; the builder dispatches on `annex_marker` and `series_head`.
    class Builder
      # The series head the grammar matched -> the model's series key
      # (the widening prefix law: every head names its publisher, and
      # the head face is the grammar's verbatim capture, so the key
      # mapping lives on the one construction site).
      SERIES_HEADS = {
        "WMO-No." => nil,
        "WMO/TD-No." => "TD",
        "JCOMM Technical Report No." => "JCOMM",
        "GAW Report No." => "GAW",
      }.freeze

      def build(parsed)
        return build_annex(parsed) if parsed[:annex_marker]
        return build_publication(parsed) if parsed[:series_head]

        Identifiers::Standard.new(**standard_attrs(parsed))
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      def build_publication(hash)
        attrs = standard_attrs(hash).merge(
          series: SERIES_HEADS.fetch(hash[:series_head]),
          volume: hash[:volume],
          edition_status: hash[:edition_status],
          updated_in: hash[:updated_in],
        ).compact

        Identifiers::Publication.new(**attrs)
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
