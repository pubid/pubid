# frozen_string_literal: true

module Pubid
  module Gost
    # Builds a GOST identifier object from the Parslet parse tree.
    class Builder
      NUMBER_YEAR_SPLIT = /\A(.+?)\s*[-—–]\s*(\d{2}|\d{4})\z/.freeze

      # Cyrillic → Latin copublisher normalization. Compound forms
      # (with /) are included.
      COPUBLISHER_MAP = {
        "ИСО" => "ISO", "МЭК" => "IEC", "ЕН" => "EN",
        "ИСО/МЭК" => "ISO/IEC", "МЭК/ИСО" => "IEC/ISO",
        "ИСО/ТУ" => "ISO/TS", "ИСО/ТО" => "ISO/TR",
        "МЭК/ТУ" => "IEC/TS", "МЭК/ТО" => "IEC/TR",
        "ИСО/МЭК/ТУ" => "ISO/IEC/TS",
      }.freeze

      # Cyrillic → Latin subtype normalization.
      SUBTYPE_MAP = {
        "МФС" => "ISP",
        "ТУ" => "TS", "ТО" => "TR",
      }.freeze

      def build(parsed)
        russian = parsed[:scope_r] ? true : false
        copublisher, subtype = split_prefix(stringify(parsed[:prefix_text]))
        number, year = split_number_year(stringify(parsed[:raw]))

        base_klass = russian ? Identifiers::NationalStandard : Identifiers::InterstateStandard
        base = base_klass.new(**{
          copublisher: copublisher,
          subtype: subtype,
          number: number,
          year: year,
          adopted_reference: stringify(parsed[:adopted_reference_raw]),
        }.compact)

        adopted_raw = stringify(parsed[:adopted_raw])
        return base unless adopted_raw

        adopted = parse_foreign(adopted_raw)
        Identifiers::IdenticalAdoption.new(base: base, adopted: adopted)
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      def split_prefix(text)
        return [nil, nil] unless text

        tokens = text.strip.split(/\s+/)
        copublisher_raw = tokens.first
        subtype_raw = tokens.size > 1 ? tokens.drop(1).join(" ") : nil

        copublisher = normalize_copublisher(copublisher_raw)
        subtype = normalize_subtype(subtype_raw)
        [copublisher, subtype]
      end

      def normalize_copublisher(raw)
        return nil unless raw
        COPUBLISHER_MAP.fetch(raw) { raw.upcase }
      end

      def normalize_subtype(raw)
        return nil unless raw
        SUBTYPE_MAP.fetch(raw) { raw }
      end

      def split_number_year(raw)
        return [raw, nil] unless raw

        m = raw.match(NUMBER_YEAR_SPLIT)
        return [raw, nil] unless m

        [m[1], m[2]]
      end

      def parse_foreign(raw)
        # Pubid doesn't auto-detect flavor from a bare string, and
        # autoloaded flavor modules may not be registered yet. Trigger
        # the autoload by referencing the constant via const_get, which
        # loads the module file (which in turn registers the flavor).
        %w[Iso Iec Ieee Astm Bsi].each do |name|
          mod = begin
            ::Pubid.const_get(name)
          rescue NameError
            next
          end

          begin
            return mod.parse(raw)
          rescue StandardError
            next
          end
        end
        nil
      end

      def stringify(value)
        return nil if value.nil?

        str = value.to_s
        str.empty? ? nil : str
      end
    end
  end
end
