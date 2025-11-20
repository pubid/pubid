# frozen_string_literal: true

require_relative "../components/date"
require_relative "components/sector"
require_relative "components/series"
require_relative "components/code"
require_relative "identifiers/recommendation"

module PubidNew
  module Itu
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        # Build components
        sector = Components::Sector.new(sector: data[:sector].to_s)
        series = Components::Series.new(series: data[:series].to_s) if data[:series]
        code = build_code(data) if data[:number]
        date = build_date(data) if data[:year]

        # For now, default to Recommendation
        Identifiers::Recommendation.new(
          sector: sector,
          series: series,
          code: code,
          date: date,
          language: data[:language]&.to_s
        )
      end

      private

      def build_code(data)
        Components::Code.new(
          number: data[:number].to_s,
          subseries: data[:subseries]&.to_s,
          parts: extract_parts(data[:parts])
        )
      end

      def build_date(data)
        PubidNew::Components::Date.new(
          year: data[:year].to_s,
          month: data[:month]&.to_s
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