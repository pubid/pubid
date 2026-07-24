# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # Supplement identifier (Suppl.)
      # Pattern: "ITU-T H Suppl. 1", "ITU-T E.156 Suppl. 2"
      class Supplement < Identifier
        attribute :base, Identifier, polymorphic: true
        attribute :number, :string

        # Compact serialization: a supplement carries only its own ordinal
        # `number`, its own date, and the nested (itself-flat) `base`. type/code
        # are delegated to `base` and NOT re-emitted. sector/series are emitted
        # ONLY for the base-less, series-only form ("ITU-T H Suppl. 1"); when a
        # base is present they are redundant copies of the base's and suppressed.
        # Inherited unchanged by Amendment / Corrigendum / Errata.
        key_value do
          map "_type", to: :_type
          map "sector",
              with: { to: :supplement_sector_to_kv, from: :sector_from_kv }
          map "series",
              with: { to: :supplement_series_to_kv, from: :series_from_kv }
          map "number", to: :number
          map "year", with: { to: :year_to_kv, from: :year_from_kv }
          map "month", with: { to: :month_to_kv, from: :month_from_kv }
          map "base", with: { to: :base_to_kv, from: :base_from_kv }
        end

        def supplement_sector_to_kv(model, doc)
          return unless model.base.nil?

          emit_kv(doc, "sector", model.sector&.sector)
        end

        def supplement_series_to_kv(model, doc)
          return unless model.base.nil?

          emit_kv(doc, "series", model.series&.series)
        end

        def to_s
          result = base ? base.to_s : "#{publisher}-#{sector}"

          # Add series if no base
          if !base && series
            result += " #{series}"
          end

          result += " Suppl. #{number}"

          # Add date if present
          if date
            result += if date.month
                        " (#{date.month}/#{date.year})"
                      else
                        " (#{date.year})"
                      end
          end

          result
        end

        def ==(other)
          return false unless other.is_a?(Supplement)

          base == other.base &&
            number == other.number &&
            date == other.date
        end
      end
    end
  end
end
