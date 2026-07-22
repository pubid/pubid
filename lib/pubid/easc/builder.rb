# frozen_string_literal: true

module Pubid
  module Easc
    # Builds an EASC identifier object from the Parslet parse tree.
    class Builder
      def build(parsed)
        series_cyr = stringify(parsed[:series])&.upcase
        canonical_series = series_to_canonical(series_cyr)
        klass = Easc.identifier_klass_for_series(canonical_series) ||
                Identifier
        attrs = {
          series:  canonical_series,
          variant: variant_to_canonical(stringify(parsed[:variant])),
          number:  stringify(parsed[:number]),
          year:    stringify(parsed[:year]),
        }.compact

        klass.new(**attrs)
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      # Map Cyrillic series to Latin canonical form (PMG/RMG). Latin
      # input is preserved as-is (uppercased).
      def series_to_canonical(series)
        return nil unless series

        case series
        when "ПМГ", "PMG" then "PMG"
        when "РМГ", "RMG" then "RMG"
        else series
        end
      end

      # Normalize variant marker to Latin "V" (regardless of script).
      def variant_to_canonical(variant)
        return nil unless variant

        %w[В V].include?(variant.upcase) ? "V" : variant
      end

      def stringify(value)
        return nil if value.nil?

        str = value.to_s
        str.empty? ? nil : str
      end
    end
  end
end
