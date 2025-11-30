# frozen_string_literal: true

require_relative "identifiers/base"
require_relative "identifiers/british_standard"
require_relative "identifiers/published_document"
require_relative "identifiers/publicly_available_specification"
require_relative "identifiers/national_annex"
require_relative "identifiers/adopted_european_norm"
require_relative "identifiers/adopted_international_standard"

module PubidNew
  module Bsi
    class Builder
      def initialize(scheme)
        @scheme = scheme
      end

      def self.build(parsed_data, scheme = Scheme.new)
        new(scheme).build(parsed_data)
      end

      def build(data)
        data = data.inject({}) { |acc, h| acc.merge(h) } if data.is_a?(Array)

        # Check for multi-level adoptions (most specific first)
        if data[:adopted_string]
          return build_adopted_identifier(data)
        end

        # Extract supplements before building base identifier
        supplements_data = extract_supplements(data)

        # Determine identifier class using Scheme
        identifier = locate_identifier_klass(data).new

        # Cast and assign each attribute
        data.each_pair do |key, value|
          realized_components = cast(key.to_sym, value)
          next if realized_components.nil?

          case realized_components
          when Hash
            realized_components.each_pair do |k, v|
              identifier.send("#{k}=", v) if identifier.respond_to?("#{k}=")
            end
          else
            identifier.send("#{key}=", realized_components) if identifier.respond_to?("#{key}=")
          end
        end

        # Wrap with consolidated if supplements present
        if supplements_data.any?
          wrap_with_consolidated(identifier, supplements_data)
        else
          identifier
        end
      end

      private

      def locate_identifier_klass(parsed_hash)
        # Special case: Handle adopted identifiers
        return Identifiers::AdoptedEuropeanNorm if parsed_hash[:adopted_string]&.match?(/EN/)
        return Identifiers::AdoptedInternationalStandard if parsed_hash[:adopted_string]

        # Use type to determine class via Scheme
        type_str = parsed_hash[:type] || parsed_hash[:stage] || ""
        typed_stage = @scheme.locate_typed_stage_by_abbr(type_str)
        @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
      end

      def cast(type, value)
        case type
        when :type
          # Lookup from register
          typed_stage = @scheme.locate_typed_stage_by_abbr(value || "")
          {
            stage: typed_stage.to_stage,
            type: typed_stage.to_type,
            typed_stage: typed_stage
          }

        when :publisher
          Components::Publisher.new(body: value.to_s)

        when :number
          Components::Code.new(value: value.to_s)

        when :parts
          # Extract parts - split by dash for multi-level parts
          parts_array = Array(value)
          if parts_array.any?
            part_str = parts_array.first[:part].to_s
            # Split on dash to get part and subpart
            part_components = part_str.split("-")
            result = { part: Components::Code.new(value: part_components.first) }
            if part_components.length > 1
              result[:subpart] = Components::Code.new(value: part_components[1])
            end
            result
          end

        when :part
          Components::Code.new(value: value[:part].to_s) if value.is_a?(Hash)

        when :year, :date
          # Return as hash with :date key for proper attribute mapping
          { date: Components::Date.new(year: value.to_i) }

        when :month
          value.to_i

        when :edition
          value.to_s

        when :adopted_string
          # Don't cast here, handled in build_adopted_identifier
          nil

        when :supplements
          # Handled separately by extract_supplements
          nil

        when :second_number, :expert_commentary, :tracked_changes, :translation, :pdf
          # Skip V1-specific attributes for now
          nil

        else
          value
        end
      end

      def build_adopted_identifier(data)
        adopted_str = data[:adopted_string]&.to_s&.strip
        return nil unless adopted_str && !adopted_str.empty?

        # Multi-level adoption hierarchy (check most specific first):
        # 1. BS EN ISO/IEC (triple-level)
        # 2. BS ISO/IEC (double-level)  
        # 3. BS EN (double-level)
        # 4. BS native

        adopted_id = nil

        # Check for EN ISO or EN IEC patterns (triple-level)
        if adopted_str.match?(/EN\s+(ISO\/IEC|IEC|ISO)/)
          # Parse the ISO/IEC part
          iso_iec_str = adopted_str.sub(/^EN\s+/, "")
          
          if iso_iec_str.start_with?("ISO/IEC") || iso_iec_str.include?("ISO/IEC")
            require_relative '../iso'
            adopted_id = PubidNew::Iso.parse(iso_iec_str)
          elsif iso_iec_str.start_with?("ISO")
            require_relative '../iso'
            adopted_id = PubidNew::Iso.parse(iso_iec_str)
          elsif iso_iec_str.start_with?("IEC")
            require_relative '../iec'
            adopted_id = PubidNew::Iec.parse(iso_iec_str)
          end

          # Wrap ISO/IEC identifier in EN adoption
          if adopted_id
            require_relative '../cen'
            adopted_id = PubidNew::Cen::Identifiers::AdoptedEuropeanNorm.new(
              publisher: ["EN"],
              adopted_identifier: adopted_id
            )
          end

        # Check for direct ISO/IEC patterns (double-level: BS ISO, BS IEC)
        elsif adopted_str.start_with?("ISO/IEC") || adopted_str.include?("ISO/IEC")
          require_relative '../iso'
          adopted_id = PubidNew::Iso.parse(adopted_str)
        elsif adopted_str.start_with?("ISO")
          require_relative '../iso'
          adopted_id = PubidNew::Iso.parse(adopted_str)
        elsif adopted_str.start_with?("IEC")
          require_relative '../iec'
          adopted_id = PubidNew::Iec.parse(adopted_str)

        # Check for EN patterns (double-level: BS EN)
        elsif adopted_str.start_with?("EN")
          require_relative '../cen'
          adopted_id = PubidNew::Cen.parse(adopted_str)
        end

        # Return appropriate wrapper based on adoption type
        if adopted_id
          # If adopted_id is already a CEN identifier (EN), use AdoptedEuropeanNorm
          if adopted_id.is_a?(PubidNew::Cen::Identifiers::Base)
            Identifiers::AdoptedEuropeanNorm.new(
              publisher: ["BS"],
              adopted_identifier: adopted_id
            )
          else
            # Otherwise it's ISO/IEC, use AdoptedInternationalStandard
            Identifiers::AdoptedInternationalStandard.new(
              publisher: ["BS"],
              adopted_identifier: adopted_id
            )
          end
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
              corrigendum_year: supp[:year]&.to_i,
              separator: supp[:separator] || "+"
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
    end
  end
end