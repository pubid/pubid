# frozen_string_literal: true

require_relative "identifiers/base"
require_relative "identifiers/european_norm"

module PubidNew
  module Cen
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        data = data.inject({}) { |acc, h| acc.merge(h) } if data.is_a?(Array)

        publishers = []
        publishers << data[:publisher].to_s if data[:publisher]
        publishers << data[:copublisher].to_s if data[:copublisher]

        parts = []
        if data[:parts]
          parts_data = data[:parts].is_a?(Array) ? data[:parts] : [data[:parts]]
          parts = parts_data.map { |p| p[:part].to_s }
        end

        # Extract supplements
        supplements_data = extract_supplements(data)

        # Build adopted identifier object if present
        adopted_id_obj = build_adopted_identifier(data)

        # Determine identifier class
        klass = locate_identifier_class(publishers, data[:stage])

        # Build base identifier
        base_id = klass.new(
          publisher: publishers.empty? ? nil : publishers,
          type: data[:type]&.to_s,
          number: data[:number].to_s,
          parts: parts.empty? ? nil : parts,
          year: data[:year]&.to_i,
          stage: data[:stage]&.to_s,
          adopted_identifier: adopted_id_obj,
          edition: data[:edition]&.to_s
        )

        # Wrap with consolidated if supplements present
        if supplements_data.any?
          wrap_with_consolidated(base_id, supplements_data)
        else
          base_id
        end
      end

      private

      def locate_identifier_class(publishers, stage)
        # Return stage-based or publisher-based class
        return Identifiers::Base if stage  # For prEN, FprEN use Base

        # Determine class by publisher combination
        case publishers.sort.join("/")
        when "EN"
          Identifiers::EuropeanNorm
        else
          Identifiers::Base  # Fallback for CEN, CLC, CWA, HD
        end
      end

      def wrap_with_consolidated(base_identifier, supplements_data)
        require_relative "identifiers/consolidated_identifier"
        require_relative "identifiers/amendment"
        require_relative "identifiers/corrigendum"

        supplement_ids = supplements_data.map do |supp|
          if supp[:type] == :amendment
            Identifiers::Amendment.new(
              base_identifier: base_identifier,
              amendment_number: supp[:number],
              amendment_year: supp[:year]&.to_i,
              separator: supp[:separator] || "+"
            )
          else
            Identifiers::Corrigendum.new(
              base_identifier: base_identifier,
              corrigendum_number: supp[:number],
              corrigendum_year: supp[:year]&.to_i
            )
          end
        end

        Identifiers::ConsolidatedIdentifier.new(
          identifiers: [base_identifier] + supplement_ids
        )
      end

      def extract_supplements(data)
        return [] unless data[:supplements]

        supps_array = data[:supplements]
        return [] if supps_array.empty?

        supps_array.map do |s|
          supp_data = s.is_a?(Hash) && s[:supplement] ? s[:supplement] : s

          # Determine separator - slash vs plus
          separator = supp_data[:amd_sep_slash] ? "/" : "+"

          {
            type: supp_data[:amd_number] ? :amendment : :corrigendum,
            number: (supp_data[:amd_number] || supp_data[:cor_number])&.to_s,
            year: (supp_data[:amd_year] || supp_data[:cor_year])&.to_s,
            separator: separator
          }
        end
      end

      def build_adopted_string(data)
        parts = []
        parts << "ISO" if data[:adopted_iso]
        parts << "IEC" if data[:adopted_iec]
        parts << "CISPR" if data[:adopted_cispr]
        parts.empty? ? nil : parts.join("/")
      end

      def build_adopted_identifier(data)
        # Parse adopted_string if present
        adopted_str = data[:adopted_string]&.to_s
        return nil unless adopted_str && !adopted_str.empty?

        # Parse with appropriate flavor parser based on prefix
        if adopted_str.start_with?("ISO")
          require_relative '../iso'
          PubidNew::Iso.parse(adopted_str)
        elsif adopted_str.start_with?("IEC")
          require_relative '../iec'
          PubidNew::Iec.parse(adopted_str)
        elsif adopted_str.start_with?("CISPR")
          # For now, return nil - CISPR might need specific handling
          nil
        else
          nil
        end
      end
    end
  end
end