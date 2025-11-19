# frozen_string_literal: true

require_relative "../components/date"
require_relative "components/code"
require_relative "components/version"
require_relative "identifiers/etsi_standard"

module PubidNew
  module Etsi
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        build_etsi_standard(data)
      end

      private

      def build_etsi_standard(data)
        # Build components
        code = build_code(data)
        version = build_version(data)
        date = build_date(data)

        # Extract amendments and corrigenda from supplements
        amendments = []
        corrigenda = []

        if data[:supplements]
          supplements_array = data[:supplements]
          supplements_array = [supplements_array] unless supplements_array.is_a?(Array)

          supplements_array.each do |supp|
            if supp[:amendment]
              amendments << supp[:amendment][:number].to_i
            elsif supp[:corrigendum]
              corrigenda << supp[:corrigendum][:number].to_i
            end
          end
        end

        Identifiers::EtsiStandard.new(
          type: data[:type].to_s,
          code: code,
          version: version,
          date: date,
          amendments: amendments.empty? ? nil : amendments,
          corrigenda: corrigenda.empty? ? nil : corrigenda
        )
      end

      def build_code(data)
        number_data = data[:number]

        # Extract number string based on format
        number = if number_data.is_a?(Hash)
          # Captured format
          if number_data[:gsm_prefix]
            # GSM with space: "GSM 11.14"
            "GSM #{number_data[:main]}.#{number_data[:sub]}"
          elsif number_data[:main] && number_data[:sub]
            # Dotted format: "11.40"
            "#{number_data[:main]}.#{number_data[:sub]}"
          elsif number_data[:prefix1]
            # Complex format: "ABC 123" or "ABC-DEF 123"
            prefix = number_data[:prefix1].to_s
            prefix += "-#{number_data[:prefix2]}" if number_data[:prefix2]
            "#{prefix} #{number_data[:num]}"
          else
            # Simple with capture
            number_data[:num].to_s
          end
        else
          number_data.to_s
        end

        parts = extract_parts(data[:parts])

        Components::Code.new(
          number: number,
          minor: data[:minor]&.to_s,
          parts: parts
        )
      end

      def build_version(data)
        # Handle both version and edition
        if data[:version]
          Components::Version.new(version: data[:version].to_s, is_edition: false)
        elsif data[:edition]
          Components::Version.new(version: data[:edition].to_s, is_edition: true)
        else
          Components::Version.new(version: "1.0.0", is_edition: false)
        end
      end

      def build_date(data)
        PubidNew::Components::Date.new(
          year: data[:year].to_s,
          month: data[:month].to_s
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