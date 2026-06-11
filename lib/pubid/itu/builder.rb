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

        # Build basic recommendation or combined identifier
        sector = Components::Sector.new(sector: data[:sector].to_s)
        series = Components::Series.new(series: data[:series].to_s) if data[:series]
        code = build_code(data) if data[:number]
        date = build_date(data) if data[:year]

        # Check if this is a combined identifier (has combined_series and combined_number)
        if data[:combined_series] || data[:combined_number]
          if data[:combined_series]
            combined_series = Components::Series.new(
              series: data[:combined_series][:series].to_s,
            )
          end

          if data[:combined_number]
            combined_code = Components::Code.new(
              number: data[:combined_number].to_s,
              subseries: data[:combined_subseries]&.to_s,
              parts: extract_parts(data[:combined_parts]),
            )
          end

          return Identifiers::CombinedIdentifier.new(
            sector: sector,
            series: series,
            code: code,
            combined_series: combined_series,
            combined_code: combined_code,
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
      # cross-bureau publication and `Identifiers::Base` rejects sector+OB
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

      def build_code(data)
        Components::Code.new(
          number: data[:number].to_s,
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
