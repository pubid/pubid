# frozen_string_literal: true

require_relative "../components/date"
require_relative "components/publisher"
require_relative "components/code"
require_relative "identifiers/international_standard"
require_relative "identifiers/guide"
require_relative "identifiers/technical_report"
require_relative "identifiers/technical_specification"
require_relative "identifiers/amendment"
require_relative "identifiers/corrigendum"
require_relative "identifiers/supplement"
require_relative "identifiers/extract"
require_relative "identifiers/data"
require_relative "identifiers/pas"
require_relative "identifiers/technology_trends_assessments"
require_relative "identifiers/international_workshop_agreement"
require_relative "identifiers/international_standardized_profile"
require_relative "identifiers/directives"
require_relative "identifiers/directives_supplement"
require_relative "identifiers/recommendation"

module PubidNew
  module Iso
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        # Convert array of hashes to single hash, collecting duplicate keys
        if data.is_a?(Array)
          data = merge_array_preserving_duplicates(data)
        end

        # Check if this is a supplement identifier (has supplements array)
        if data[:supplements]&.any?
          return build_supplement_identifier(data)
        end

        # Extract base data if present
        base_data = data[:base] || data

        # Convert base_data if it's an array of hashes
        if base_data.is_a?(Array)
          base_data = merge_array_preserving_duplicates(base_data)
        end

        # Build publisher
        publisher = build_publisher(base_data)

        # Build number and parts
        number_data = build_number_data(base_data)

        # Determine type - typed_stage may contain type info
        type_str = extract_type(base_data)
        stage_str = extract_stage(base_data)

        # Select appropriate class based on type
        klass = determine_identifier_class(type_str, base_data)

        # Special handling for DirectivesSupplement - it needs a base identifier
        if klass == Identifiers::DirectivesSupplement
          # Build the Directives base identifier
          directives_base = Identifiers::Directives.new(
            publisher: publisher,
            type: type_str ? ::PubidNew::Components::Type.new(abbr: type_str) : nil,
            number: number_data[:number],
            part: number_data[:part],
            date: nil, # Date goes on supplement, not base
            stage: stage_str ? ::PubidNew::Components::Stage.new(value: stage_str) : nil,
            stage_iteration: base_data[:iteration] ? ::PubidNew::Components::Code.new(value: base_data[:iteration]&.to_s) : nil,
            languages: base_data[:language] ? [::PubidNew::Components::Language.new(original_code: base_data[:language]&.to_s)] : nil,
          )

          # Extract supplement_publisher
          supplement_publisher = nil
          if base_data[:sup_publisher]
            sup_pub_data = base_data[:sup_publisher]
            sup_pub_str = if sup_pub_data.is_a?(Hash)
                            sup_pub_data[:publisher]&.to_s
                          else
                            sup_pub_data.to_s
                          end
            supplement_publisher = Components::Publisher.new(publisher: sup_pub_str) if sup_pub_str
          end

          # Create DirectivesSupplement with base
          return Identifiers::DirectivesSupplement.new(
            base_identifier: directives_base,
            supplement_publisher: supplement_publisher,
            date: base_data[:year] ? ::PubidNew::Components::Date.new(year: base_data[:year]&.to_i) : nil,
          )
        end

        klass.new(
          publisher: publisher,
          type: type_str && type_str != "Guide" && type_str != "GUIDE" ? ::PubidNew::Components::Type.new(abbr: type_str) : nil,
          number: number_data[:number],
          part: number_data[:part],
          date: base_data[:year] ? ::PubidNew::Components::Date.new(year: base_data[:year]&.to_i) : nil,
          stage: stage_str ? ::PubidNew::Components::Stage.new(value: stage_str) : nil,
          stage_iteration: base_data[:iteration] ? ::PubidNew::Components::Code.new(value: base_data[:iteration]&.to_s) : nil,
          languages: base_data[:language] ? [::PubidNew::Components::Language.new(original_code: base_data[:language]&.to_s)] : nil,
        )
      end

      private

      # Merge array of hashes, collecting duplicate keys into arrays
      def merge_array_preserving_duplicates(array)
        array.inject({}) do |acc, h|
          h.each do |key, value|
            if acc.key?(key)
              # Convert to array if not already
              acc[key] = [acc[key]] unless acc[key].is_a?(Array)
              acc[key] << value
            else
              acc[key] = value
            end
          end
          acc
        end
      end

      def build_supplement_identifier(data)
        # Build base identifier first
        base_data = data[:base] || data
        base_identifier = build(base_data)

        # Process supplements recursively, each wrapping the previous
        current_base = base_identifier

        data[:supplements].each do |supplement_data|
          # Determine supplement type from both supplement_type and typed_stage
          supplement_type = supplement_data[:supplement_type]&.to_s&.downcase

          # Extract typed_stage - parser returns nested {:typed_stage=>{:typed_stage=>"FDAM"}}
          typed_stage_str = if supplement_data[:typed_stage].is_a?(Hash)
                              supplement_data[:typed_stage][:typed_stage]&.to_s
                            else
                              supplement_data[:typed_stage]&.to_s
                            end

          # Select appropriate supplement class
          supplement_class = if supplement_type
                               case supplement_type
                               when /amd/
                                 Identifiers::Amendment
                               when /cor/
                                 Identifiers::Corrigendum
                               when /suppl/
                                 Identifiers::Supplement
                               when /ext/
                                 Identifiers::Extract
                               else
                                 Identifiers::Supplement
                               end
                             elsif typed_stage_str
                               # Infer from typed_stage when supplement_type is missing
                               case typed_stage_str.upcase
                               when /DAM/, /AMD/
                                 Identifiers::Amendment
                               when /COR/
                                 Identifiers::Corrigendum
                               else
                                 Identifiers::Supplement
                               end
                             else
                               Identifiers::Supplement
                             end

          # Extract stage from typed_stage
          stage_str = extract_supplement_stage(typed_stage_str)

          # Find typed_stage - if no stage string, use published stage as default
          typed_stage = if stage_str
                          find_typed_stage(supplement_class, stage_str)
                        else
                          # Default to published stage for the supplement class
                          find_published_typed_stage(supplement_class)
                        end

          # Create this supplement with current_base as its base
          current_base = supplement_class.new(
            base_identifier: current_base,
            number: ::PubidNew::Components::Code.new(value: supplement_data[:supplement_number]&.to_s&.strip),
            date: supplement_data[:year] ? ::PubidNew::Components::Date.new(year: supplement_data[:year]&.to_i) : nil,
            typed_stage: typed_stage,
          )
        end

        # Return the outermost supplement
        current_base
      end

      def find_typed_stage(klass, stage_abbr)
        return nil unless klass.const_defined?(:TYPED_STAGES)

        klass::TYPED_STAGES.find do |ts|
          ts.abbr.any? { |a| a.upcase == stage_abbr.upcase }
        end
      end

      def find_published_typed_stage(klass)
        return nil unless klass.const_defined?(:TYPED_STAGES)

        # Find the published stage (stage_code is "published")
        klass::TYPED_STAGES.find do |ts|
          ts.stage_code.to_s == "published"
        end
      end

      def extract_supplement_stage(typed_stage)
        return nil unless typed_stage

        case typed_stage
        when /^FDAM/
          "FDAM"
        when /^PDAM/
          "PDAM"
        when /^DAM/
          "DAM"
        when /^FDCOR/
          "FDCOR"
        when /^DCOR/
          "DCOR"
        else
          typed_stage
        end
      end

      def determine_identifier_class(type_str, data = {})
        case type_str&.upcase
        when "GUIDE"
          Identifiers::Guide
        when "TR"
          Identifiers::TechnicalReport
        when "TS"
          Identifiers::TechnicalSpecification
        when "DATA"
          Identifiers::Data
        when "PAS"
          Identifiers::Pas
        when "TTA"
          Identifiers::TechnologyTrendsAssessments
        when "IWA"
          Identifiers::InternationalWorkshopAgreement
        when "ISP"
          Identifiers::InternationalStandardizedProfile
        when "DIR"
          # Check if it's a supplement to directives (has SUP fields)
          if data[:sup_type] || data[:sup_publisher]
            Identifiers::DirectivesSupplement
          else
            Identifiers::Directives
          end
        when "SUP"
          Identifiers::DirectivesSupplement
        when "R"
          Identifiers::Recommendation
        else
          Identifiers::InternationalStandard
        end
      end

      def extract_type(data)
        # Typed stages like "DTR" mean  "Draft TR"
        if data[:typed_stage]
          ts = data[:typed_stage].to_s
          return "TR" if ts.include?("TR")
          return "TS" if ts.include?("TS")
        end

        data[:type]&.to_s
      end

      def extract_stage(data)
        # Typed stages like "DTR" mean type=TR, stage=Draft
        if data[:typed_stage]
          ts = data[:typed_stage].to_s
          return "CD" if ts.start_with?("D") && !ts.start_with?("DIS")
          return "DIS" if ts == "DIS"
          return "FDIS" if ts == "FDIS"

          return ts
        end

        data[:stage]&.to_s
      end

      def build_publisher(data)
        copubs = []
        # Handle copublisher - parser may return single hash or array
        if data.key?(:copublisher) && data[:copublisher]
          copub_data = data[:copublisher]

          # If it's an array, iterate
          if copub_data.is_a?(Array)
            copub_data.each do |item|
              if item.is_a?(Hash)
                # Each item might have nested :copublisher key
                val = item[:copublisher] || item
                copubs << val.to_s if val
              else
                copubs << item.to_s
              end
            end
          elsif copub_data.is_a?(Hash)
            # Single hash with nested :copublisher
            val = copub_data[:copublisher] || copub_data
            copubs << val.to_s if val
          else
            # Direct string value
            copubs << copub_data.to_s
          end
        end

        Components::Publisher.new(
          publisher: data[:publisher]&.to_s || "ISO",
          copublisher: copubs.empty? ? nil : copubs,
        )
      end

      def build_number_data(data)
        # Extract parts if present
        parts = []
        if data[:parts].is_a?(Array) && data[:parts].any?
          parts = data[:parts].map { |p| p[:part].to_s }
        end

        result = {}
        if data[:number]
          result[:number] =
            ::PubidNew::Components::Code.new(value: data[:number].to_s)
        end
        if parts.first
          result[:part] =
            ::PubidNew::Components::Code.new(value: parts.first)
        end
        result
      end
    end
  end
end
