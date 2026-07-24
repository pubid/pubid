# frozen_string_literal: true

module Pubid
  module Itu
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        # "Annex to ..." identifier — wraps a Special Publication base
        if data[:annex_to]
          return build_annex(data[:annex_to])
        end

        # Operational Bulletin (Special Publication) — series == "OB" or
        # legacy long form ("Operational Bulletin No. ...").
        if data[:series].to_s == "OB" || data[:_op_bull]
          return build_special_publication(data)
        end

        # Check if this is a supplement identifier
        if data[:supplement_type]
          return build_supplement(data)
        end

        # Handbook — "ITU-R 42.HDB"
        if data[:handbook_marker]
          return build_handbook(data)
        end

        # Question — numeric ("ITU-R 234-1/7:") or letter-series
        # ("ITU-R P.3/BL/7"). Both carry a :study_group marker.
        if data[:study_group]
          return build_question(data)
        end

        # Build basic recommendation or combined identifier
        sector = Components::Sector.new(sector: data[:sector].to_s)
        series = Components::Series.new(series: data[:series].to_s) if data[:series]
        code = build_code(data) if data[:number]
        date = build_date(data) if data[:year]

        # Combined (joint) recommendation — one or more additional
        # "/SERIES.CODE" designations after the primary (e.g. "G.780/Y.1351",
        # "G.780/Y.1351/Z.1362"). The primary stays on the base series/code.
        if data[:combined]
          return Identifiers::CombinedIdentifier.new(
            sector: sector,
            series: series,
            code: code,
            combined: build_designations(data[:combined]),
            date: date,
            language: data[:language]&.to_s,
          )
        end

        Identifiers::Recommendation.new(
          sector: sector,
          series: series,
          code: code,
          date: date,
          language: data[:language]&.to_s,
        )
      end

      # Build Special Publication (OB). Sector is silently dropped — OB is a
      # cross-bureau publication and `Identifier` rejects sector+OB
      # in its constructor.
      def build_special_publication(data)
        Identifiers::SpecialPublication.new(
          series: Components::Series.new(series: "OB"),
          code: data[:number] ? build_code(data) : nil,
          date: data[:year] ? build_date(data) : nil,
          language: data[:language]&.to_s,
        )
      end

      # Build "Annex to ..." identifier. The inner data is the Special
      # Publication; the annex inherits its language.
      def build_annex(inner_data)
        base = build_special_publication(inner_data)
        Identifiers::Annex.new(
          base: base,
          language: inner_data[:language]&.to_s,
        )
      end

      # Build Handbook ("ITU-R 42.HDB").
      def build_handbook(data)
        Identifiers::Handbook.new(
          sector: Components::Sector.new(sector: data[:sector].to_s),
          code: build_code(data),
          date: data[:year] ? build_date(data) : nil,
        )
      end

      # Build Question (numeric or letter-series).
      def build_question(data)
        series = if data[:series]
                   Components::Series.new(series: data[:series].to_s)
                 end

        Identifiers::Question.new(
          sector: Components::Sector.new(sector: data[:sector].to_s),
          series: series,
          code: build_code(data),
          study_group: data[:study_group].to_s,
          has_bl: !data[:has_bl].nil?,
          bracketed: !data[:bracketed].nil?,
          has_colon: !data[:question_colon].nil?,
        )
      end

      def build_supplement(data)
        # Build the base identifier first
        base = build(data[:base]) if data[:base]

        # Determine supplement type
        supplement_type = data[:supplement_type].to_s.gsub(".", "")
        klass = case supplement_type
                when "Amd"
                  Identifiers::Amendment
                when "Cor"
                  Identifiers::Corrigendum
                when "Err"
                  Identifiers::Errata
                when "Suppl"
                  Identifiers::Supplement
                end

        # Build supplement date (separate from base date)
        supplement_date = if data[:supplement_year]
                            Pubid::Components::Date.new(
                              year: data[:supplement_year].to_s,
                              month: data[:supplement_month]&.to_s,
                            )
                          end

        # Build supplement with extracted components
        klass.new(
          sector: base&.sector || Components::Sector.new(sector: data[:sector].to_s),
          series: base&.series || (data[:series] ? Components::Series.new(series: data[:series].to_s) : nil),
          code: base&.code,
          base: base,
          number: data[:supplement_number].to_s,
          date: supplement_date,
          language: data[:language]&.to_s,
        )
      end

      private

      # Build the additional designations of a combined recommendation from the
      # repeated parse subtrees (each `{ designation: { series:, number:, … } }`).
      def build_designations(combined_data)
        Array(combined_data).map do |element|
          d = element[:designation] || element
          Components::Designation.new(
            series: Components::Series.new(series: d[:series].to_s),
            code: Components::Code.new(
              number: d[:number].to_s,
              subseries: d[:subseries]&.to_s,
              parts: extract_parts(d[:parts]),
            ),
          )
        end
      end

      def build_code(data)
        Components::Code.new(
          imp_marker: data[:imp_marker]&.to_s,
          number: data[:number].to_s,
          series_suffix: data[:series_suffix]&.to_s,
          subseries: data[:subseries]&.to_s,
          parts: extract_parts(data[:parts]),
        )
      end

      def build_date(data)
        Pubid::Components::Date.new(
          year: data[:year].to_s,
          month: data[:month]&.to_s,
        )
      end

      def extract_parts(parts_data)
        return [] unless parts_data

        parts = []
        if parts_data.is_a?(Array)
          parts_data.each do |part_hash|
            parts << part_hash[:part].to_s if part_hash[:part]
          end
        elsif parts_data.is_a?(Hash) && parts_data[:part]
          parts << parts_data[:part].to_s
        end

        parts
      end
    end
  end
end
