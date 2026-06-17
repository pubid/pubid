# frozen_string_literal: true

module Pubid
  module Nist
    # Normalizes the raw hash produced by the NIST parser before the Builder
    # constructs the identifier object.
    #
    # The parser emits a flat hash with keys like :first_number, :second_number,
    # :edition_dash_year, :update_prefix, etc. Many of those keys are
    # *incompatible shapes* — e.g. parser captures a year as :edition_dash_year
    # when it is actually a second_number, or a letter+digits suffix lives
    # inside :first_number when it should become a Part component.
    #
    # Each `normalize_*` method here performs one such shape correction,
    # mutating the hash in place. The Normalizer is intentionally
    # *side-effect-only*: it never reads from the Builder, the Caster, or the
    # identifier classes, so it can be tested in isolation.
    #
    # Pre-processing blocks that need to surface extracted components to the
    # Builder (e.g. letter-suffix Part components, embedded-edition objects)
    # remain in Builder#build because they create local variables that flow
    # into the construction phase. All other normalizations live here.
    class ParserOutputNormalizer
      # Range of years we treat as "looks like a calendar year" when
      # disambiguating :edition_dash_year from :second_number.
      VALID_YEAR_RANGE = (1901..2026).freeze

      # Series that treat :edition_dash_year as a year-only edition when the
      # dash year falls in VALID_YEAR_RANGE. For other series with a dash-year
      # in this range, the dash-year is interpreted differently (or kept as
      # a compound number, depending on the branch).
      DASH_YEAR_AS_EDITION_SERIES = %w[HB CS FIPS].freeze

      # Apply all normalizations to the parsed hash in the correct order.
      # @param parsed_hash [Hash] parser output (mutated in place)
      # @return [Hash] the same hash, normalized
      def normalize(parsed_hash)
        merge_edition_e_into_update(parsed_hash)
        extract_embedded_edition_with_year(parsed_hash)
        extract_embedded_edition_without_dash_year(parsed_hash)
        split_second_number_edition_year(parsed_hash)
        split_fips_month_year_after_part(parsed_hash)
        disambiguate_ir_compound_vs_edition(parsed_hash)
        disambiguate_dash_year(parsed_hash)
        parsed_hash
      end

      private

      # Pattern: "800-53r4/Upd3-2015"
      # Parser captures "-2015" as :edition_e but it belongs on :update.
      def merge_edition_e_into_update(parsed_hash)
        return unless parsed_hash[:update_prefix] && parsed_hash[:update] && parsed_hash[:edition_e]

        edition_id = parsed_hash[:edition_e][:edition_id]
        parsed_hash[:update] = parsed_hash[:update].merge(update_year: edition_id)
        parsed_hash.delete(:edition_e)
      end

      # Pattern: "44e2-1955"
      # first_number="44e2", edition_dash_year="1955"
      # Result: first_number="44", edition(type:"e", id:"2", additional_text:"1955")
      def extract_embedded_edition_with_year(parsed_hash)
        return unless parsed_hash[:first_number]&.to_s&.match?(/^[0-9]+[a-zA-Z]\d+$/) &&
                      parsed_hash[:edition_dash_year]

        number_str = parsed_hash[:first_number].to_s
        return unless (match_data = number_str.match(/^(\d+)([a-zA-Z])(\d+)$/))

        base_number, edition_type, edition_id = match_data[1], match_data[2].downcase, match_data[3]

        parsed_hash[:first_number] = Components::Code.new(value: base_number)
        parsed_hash[:edition_with_year] = Components::Edition.new(
          type: edition_type,
          id: edition_id,
          additional_text: parsed_hash[:edition_dash_year][:dash_year],
        )
        parsed_hash.delete(:edition_dash_year)
      end

      # Pattern: "8115r1" (with no edition_dash_year)
      # first_number="8115r1", no second_number
      # Result: first_number="8115", edition(type:"r", id:"1")
      #
      # CRITICAL: Only when no :second_number is present, otherwise the
      # compound-number logic in the Builder handles the pattern.
      def extract_embedded_edition_without_dash_year(parsed_hash)
        return if parsed_hash[:second_number]
        return unless parsed_hash[:first_number]&.to_s&.match?(/^[0-9]+[a-zA-Z]\d+$/)
        return if parsed_hash[:edition_dash_year]

        number_str = parsed_hash[:first_number].to_s
        return unless (match_data = number_str.match(/^(\d+)([a-zA-Z])(\d+)$/))

        base_number, edition_type, edition_id = match_data[1], match_data[2].downcase, match_data[3]

        parsed_hash[:first_number] = Components::Code.new(value: base_number)
        parsed_hash[:edition_with_year] = Components::Edition.new(
          type: edition_type,
          id: edition_id,
        )
      end

      # Pattern: "105-1-1990"
      # Parser returns second_number_edition_year={second_number:"1", dash_year:"1990"}
      # Result: :second_number="1", plus either :edition_from_year (HB series)
      # or :edition_dash_year (other series) for further downstream processing.
      def split_second_number_edition_year(parsed_hash)
        return unless parsed_hash[:second_number_edition_year]

        combined = parsed_hash[:second_number_edition_year]
        parsed_hash[:second_number] = combined[:second_number]
        dash_year = combined[:dash_year]

        is_handbook = safely_to_s(parsed_hash[:series]) == "HB"
        if is_handbook && dash_year.to_s.match?(/^\d{4}$/)
          parsed_hash[:edition_from_year] = Components::Edition.new(type: "e", id: dash_year)
        else
          parsed_hash[:edition_dash_year] = { dash_year: dash_year }
        end

        parsed_hash.delete(:second_number_edition_year)
      end

      # Pattern: "11-1-Sep1977"
      # Parser returns fips_month_year_after_part={second_number:"1", edition_month:"Sep", edition_year:"1977"}
      # Result: :second_number="1", :edition_from_year(type:"e", id:"197709")
      def split_fips_month_year_after_part(parsed_hash)
        return unless parsed_hash[:fips_month_year_after_part]

        combined = parsed_hash[:fips_month_year_after_part]
        parsed_hash[:second_number] = combined[:second_number]
        month_str = combined[:edition_month]
        year_str = combined[:edition_year]

        month_num = month_to_number(month_str)
        edition_id = month_num&.positive? ? "#{year_str}#{format('%02d', month_num)}" : year_str

        parsed_hash[:edition_from_year] = Components::Edition.new(type: "e", id: edition_id)
        parsed_hash.delete(:fips_month_year_after_part)
      end

      # Pattern: "84-2946" with series=IR
      # For IR (Interagency Report), a 2-digit first_number followed by a
      # 4-digit dash-year is *almost* always a year-only edition (e.g.
      # "76e1100") — except when the 4-digit number is clearly not a year
      # (>= 2700) or there is an embedded :edition_e (compound number).
      def disambiguate_ir_compound_vs_edition(parsed_hash)
        return unless safely_to_s(parsed_hash[:series]) == "IR"
        return unless parsed_hash[:first_number] && parsed_hash[:edition_dash_year]

        first_num = parsed_hash[:first_number].to_s
        dash_year = parsed_hash[:edition_dash_year][:dash_year].to_s
        return unless first_num.match?(/^\d{2}$/) && dash_year.match?(/^\d{4}$/)

        dash_year_num = dash_year.to_i
        is_valid_year = VALID_YEAR_RANGE.cover?(dash_year_num)
        has_embedded_edition = parsed_hash[:edition_e]

        if is_valid_year && !has_embedded_edition
          parsed_hash[:first_number] = Components::Code.new(value: first_num)
          parsed_hash[:edition] = Components::Edition.new(type: "e", id: dash_year)
        else
          parsed_hash[:first_number] = Components::Code.new(value: "#{first_num}-#{dash_year}")
        end
        parsed_hash.delete(:edition_dash_year)
      end

      # Pattern: "250-1039" or "15-1000" or "1946-1947" (RPT)
      # When the parser captures a :first_number plus :edition_dash_year, the
      # dash year is interpreted differently per series:
      # - RPT: always join into a compound (date range), regardless of year
      # - GCR: always convert dash-year to year-only edition
      # - IR: convert dash-year to year-only edition only if it is a valid year
      # - HB/CS/FIPS: convert dash-year to year-only edition only if valid year
      # - others: drop :edition_dash_year, or stash as :second_number if < 1900
      def disambiguate_dash_year(parsed_hash)
        return unless parsed_hash[:first_number] && parsed_hash[:edition_dash_year]
        return if parsed_hash[:first_number].to_s.match?(/^[0-9]+[a-zA-Z]\d+$/)

        dash_year = parsed_hash[:edition_dash_year][:dash_year].to_s
        series = safely_to_s(parsed_hash[:series])
        dash_year_num = dash_year.to_i
        is_valid_year = VALID_YEAR_RANGE.cover?(dash_year_num)

        if series == "RPT"
          # RPT date ranges: "1946-1947" -> "1946-1947"
          parsed_hash[:first_number] =
            Components::Code.new(value: "#{parsed_hash[:first_number]}-#{dash_year}")
          parsed_hash.delete(:edition_dash_year)
        elsif series == "GCR"
          # GCR always converts dash-year to edition
          stash_edition_from_year(parsed_hash, dash_year)
        elsif series == "IR" && is_valid_year
          # IR converts valid years to edition
          stash_edition_from_year(parsed_hash, dash_year)
        elsif DASH_YEAR_AS_EDITION_SERIES.include?(series) && is_valid_year
          # HB/CS/FIPS: convert dash-year to edition only if valid year
          stash_edition_from_year(parsed_hash, dash_year)
        elsif dash_year_num < 1900
          # For other series, dash-year < 1900 is a second_number
          parsed_hash[:second_number] = dash_year
          parsed_hash.delete(:edition_dash_year)
        end
        # Other cases (non-HB/CS/FIPS with a valid year): leave the keys alone
        # so downstream Builder logic can handle them.
      end

      # Convert dash-year into a year-only Edition and stash for the Builder
      # to assign after construction.
      def stash_edition_from_year(parsed_hash, dash_year)
        parsed_hash[:edition_from_year] = Components::Edition.new(type: "e", id: dash_year)
        parsed_hash.delete(:edition_dash_year)
      end

      # Safely coerce arbitrary values to strings (parsers can hand us Parslet
      # nodes that raise on #to_s in some scenarios).
      def safely_to_s(value)
        value.to_s
      rescue StandardError
        ""
      end

      # Convert a month abbreviation or name to a 1-based month number.
      # Returns nil when the value is not a recognizable month.
      def month_to_number(month_str)
        Date::ABBR_MONTHNAMES.index(month_str) ||
          Date::MONTHNAMES.index(month_str) ||
          month_str.to_i
      end
    end
  end
end
