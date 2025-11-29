# frozen_string_literal: true

require_relative "identifiers/base"
require_relative "identifiers/european_norm"
require_relative "identifiers/adopted_european_norm"
require_relative "identifiers/technical_specification"
require_relative "identifiers/technical_report"
require_relative "identifiers/cen_workshop_agreement"
require_relative "identifiers/guide"
require_relative "identifiers/harmonization_document"

module PubidNew
  module Cen
    class Builder
      def initialize(scheme)
        @scheme = scheme
      end

      def self.build(parsed_data, scheme = Scheme.new)
        new(scheme).build(parsed_data)
      end

      def build(data)
        data = data.inject({}) { |acc, h| acc.merge(h) } if data.is_a?(Array)

        # Check if this is an adopted identifier (EN ISO, EN IEC, etc.)
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
        # Special case: Use adopted_european_norm for adopted identifiers
        return Identifiers::AdoptedEuropeanNorm if parsed_hash[:adopted_string]

        # Check if publisher is actually a type code (CWA, HD act as publisher)
        publisher_str = parsed_hash[:publisher].to_s
        if %w[CWA HD].include?(publisher_str)
          typed_stage = @scheme.locate_typed_stage_by_abbr(publisher_str)
          return @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
        end

        # Use type or stage to determine class via Scheme
        type_or_stage = parsed_hash[:type_with_stage] || parsed_hash[:type] || parsed_hash[:stage] || ""
        typed_stage = @scheme.locate_typed_stage_by_abbr(type_or_stage)
        @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
      end

      def cast(type, value)
        case type
        when :type_with_stage
          # Lookup from register
          typed_stage = @scheme.locate_typed_stage_by_abbr(value || "")
          {
            stage: typed_stage.to_stage,
            type: typed_stage.to_type,
            typed_stage: typed_stage
          }

        when :publisher
          Components::Publisher.new(body: value.to_s)

        when :copublisher
          # Map singular :copublisher to :copublishers array
          { copublishers: [Components::Publisher.new(body: value.to_s)] }

        when :copublishers
          # Handle array of copublishers
          Array(value).map { |v| Components::Publisher.new(body: v[:copublisher].to_s) }

        when :number
          Components::Code.new(value: value.to_s)

        when :parts
          # Extract first part as :part, rest as :subpart if needed
          parts_array = Array(value)
          if parts_array.any?
            # Return hash with :part (and potentially :subpart)
            result = { part: Components::Code.new(value: parts_array.first[:part].to_s) }
            if parts_array.length > 1
              result[:subpart] = Components::Code.new(value: parts_array[1][:part].to_s)
            end
            result
          end

        when :part
          Components::Code.new(value: value[:part].to_s) if value.is_a?(Hash)

        when :year, :date
          # Return as hash with :date key for proper attribute mapping
          { date: Components::Date.new(year: value.to_i) }

        when :type
          Components::Type.new(abbr: value.to_s)

        when :stage
          Components::Stage.new(abbr: value.to_s)

        when :edition
          value.to_s

        when :adopted_string
          # Don't cast here, handled in build_adopted_identifier
          nil

        when :supplements
          # Handled separately by extract_supplements
          nil

        else
          value
        end
      end

      def build_adopted_identifier(data)
        # Parse the adopted identifier string with appropriate flavor
        adopted_str = data[:adopted_string]&.to_s&.strip
        return nil unless adopted_str && !adopted_str.empty?

        adopted_id = if adopted_str.start_with?("ISO/IEC") || adopted_str.include?("ISO/IEC")
          require_relative '../iso'
          PubidNew::Iso.parse(adopted_str)
        elsif adopted_str.start_with?("ISO")
          require_relative '../iso'
          PubidNew::Iso.parse(adopted_str)
        elsif adopted_str.start_with?("IEC")
          require_relative '../iec'
          PubidNew::Iec.parse(adopted_str)
        elsif adopted_str.start_with?("CISPR")
          # CISPR might need specific handling
          nil
        end

        # Build publishers array (EN is default for adoptions)
        publishers = []
        publishers << data[:publisher].to_s if data[:publisher]
        
        # Handle copublishers array
        if data[:copublishers]
          Array(data[:copublishers]).each do |copub|
            publishers << copub[:copublisher].to_s
          end
        elsif data[:copublisher]
          publishers << data[:copublisher].to_s
        end
        
        publishers = ["EN"] if publishers.empty?

        Identifiers::AdoptedEuropeanNorm.new(
          publisher: publishers,
          adopted_identifier: adopted_id
        )
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
    end
  end
end