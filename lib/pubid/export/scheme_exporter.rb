# frozen_string_literal: true

module Pubid
  module Export
    # Strategy for flavors using Scheme with class-level identifiers method
    # and def self.type / TYPED_STAGES patterns.
    #
    # Covers: ISO, IEC, ASTM, ASHRAE, ASME, CCSDS, CIE, CSA, JIS, JCGM,
    #         OIML, IDF, API, SAE, NIST, IEEE
    class SchemeExporter < FlavorExporter
      def export
        klasses = identifier_classes
        return nil if klasses.empty?

        fixture_data = fixture_examples

        identifier_types = klasses.filter_map do |klass|
          info = extract_type_info(klass)
          stages = extract_typed_stages(klass)
          type_key = info[:key]&.to_s

          # Match fixture examples to this type
          examples = match_examples(fixture_data, type_key, klass)

          IdentifierTypeResult.new(
            key: info[:key],
            title: info[:title],
            short: info[:short],
            abbr: info[:abbr],
            typed_stages: stages,
            examples: examples,
          )
        end

        all_attrs = klasses.first ? extract_attributes(klasses.first) : []
        wrapper_types = extract_wrapper_types

        FlavorResult.new(
          flavor: flavor,
          identifier_types: identifier_types,
          wrapper_types: wrapper_types,
          attributes: all_attrs,
        )
      end

      private

      def match_examples(fixture_data, type_key, klass)
        return [] unless type_key

        # Try direct type key match first
        examples = fixture_data[map_fixture_key_to_type_key(type_key)] ||
          fixture_data[map_fixture_key_to_type_key(type_key.gsub("_",
                                                                 ""))] ||
          []

        return examples if examples.any?

        # Try class name match
        class_name = klass.name&.split("::")&.last
        snake_name = class_name&.gsub(/([A-Z])/, '_\1')&.downcase&.sub(/^_/, "")
        if snake_name && fixture_data.key?(snake_name)
          fixture_data[snake_name]
        else
          []
        end
      end
    end
  end
end
