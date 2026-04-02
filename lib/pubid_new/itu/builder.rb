# frozen_string_literal: true

require_relative "../components/date"
require_relative "components/sector"
require_relative "components/series"
require_relative "components/code"
require_relative "identifiers/recommendation"
require_relative "identifiers/combined_identifier"
require_relative "identifiers/supplement"
require_relative "identifiers/amendment"
require_relative "identifiers/corrigendum"

module PubidNew
  module Itu
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
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
                            PubidNew::Components::Date.new(
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
        PubidNew::Components::Date.new(
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
