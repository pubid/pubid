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
        base = build_base(parsed)
        with_foreign_adoption(base, parsed)
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      def build_base(parsed)
        russian = parsed[:scope_r] ? true : false
        copublisher, subtype = split_prefix(stringify(parsed[:prefix_text]))
        number, year = split_number_year(stringify(parsed[:raw]))

        klass = russian ? Identifiers::NationalStandard : Identifiers::InterstateStandard
        klass.new(**{
          copublisher: copublisher,
          subtype: subtype,
          number: number,
          year: year,
        }.compact)
      end

      # Apply the slash (IdenticalAdoption) and/or parens (Harmonized)
      # wrappers around the base standard. Both can apply simultaneously.
      def with_foreign_adoption(base, parsed)
        wrapper = wrap_identical_adoption(base, parsed)
        wrap_harmonized(wrapper, parsed)
      end

      def wrap_identical_adoption(base, parsed)
        adopted_raw = stringify(parsed[:adopted_raw])
        return base unless adopted_raw

        adopted = parse_foreign(adopted_raw)
        Identifiers::IdenticalAdoption.new(base: base, adopted: adopted)
      end

      def wrap_harmonized(base, parsed)
        reference_raw = stringify(parsed[:adopted_reference_raw])
        return base unless reference_raw

        items = reference_raw.split(",").map(&:strip).map { |s| normalize_foreign(s) }
        adopted = items.map { |item| adopt_identifier(item) }

        Identifiers::Harmonized.new(base: base, adopted_identifiers: adopted)
      end

      # Parse a single foreign identifier, falling back to a
      # ForeignReference that preserves the raw surface form when no
      # registered flavor recognizes it (e.g. OECD, UNECE STANDARD).
      def adopt_identifier(raw)
        parse_foreign(raw) || Identifiers::ForeignReference.new(raw: raw)
      end

      def split_prefix(text)
        return [nil, nil] unless text

        tokens = text.strip.split(/\s+/)
        copublisher_raw = tokens.first
        subtype_raw = tokens.size > 1 ? tokens.drop(1).join(" ") : nil

        [normalize_copublisher(copublisher_raw), normalize_subtype(subtype_raw)]
      end

      def normalize_copublisher(raw)
        return nil unless raw
        COPUBLISHER_MAP.fetch(raw) { raw.upcase }
      end

      def normalize_subtype(raw)
        return nil unless raw
        SUBTYPE_MAP.fetch(raw) { raw }
      end

      # Normalize a leading Cyrillic publisher token (e.g. "ИСО") to its
      # Latin equivalent so a foreign parser can recognize it. Longest
      # keys first so "ИСО/МЭК" wins over "ИСО".
      def normalize_foreign(raw)
        COPUBLISHER_MAP.keys.sort_by(&:length).reverse.each do |cyr|
          next unless raw.start_with?(cyr + " ") || raw.start_with?(cyr + "/")

          return COPUBLISHER_MAP[cyr] + raw[cyr.length..]
        end
        raw
      end

      def split_number_year(raw)
        return [raw, nil] unless raw

        m = raw.match(NUMBER_YEAR_SPLIT)
        return [raw, nil] unless m

        [m[1], m[2]]
      end

      # Try every registered flavor (other than GOST itself) as a parser
      # for a foreign adopted identifier. Returns the first successful
      # parse, or nil if none recognize the string.
      def parse_foreign(raw)
        ::Pubid.eager_load_flavors!
        ::Pubid::Registry.flavors.each_value do |mod|
          next if mod == ::Pubid::Gost

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
