# frozen_string_literal: true

module Pubid
  module Export
    # Strategy for NIST, which has a unique identifier architecture:
    # per-class typed_stages class method (not TYPED_STAGES constant),
    # and a Scheme.identifiers class method.
    class NistExporter < FlavorExporter
      def export
        scheme = scheme_class
        return nil unless scheme

        klasses = scheme.identifiers.reject { |k| k == scheme_module::Identifiers::Base }
        fixture_data = fixture_examples

        seen_keys = Set.new
        identifier_types = klasses.filter_map do |klass|
          info = extract_type_info(klass)
          type_key = info[:key]
          next if seen_keys.include?(type_key)

          seen_keys << type_key

          examples = match_nist_examples(fixture_data, type_key, klass)
          stages = klass.methods.include?(:typed_stages) ? klass.typed_stages : []

          IdentifierTypeResult.new(
            key: info[:key],
            title: info[:title],
            short: info[:short],
            abbr: stages.flat_map(&:abbr),
            typed_stages: stages,
            examples: examples,
          )
        end

        FlavorResult.new(
          flavor: flavor,
          identifier_types: identifier_types,
          attributes: klasses.first ? extract_attributes(klasses.first) : [],
        )
      end

      private

      def match_nist_examples(fixture_data, type_key, klass)
        return [] unless type_key

        # NIST fixtures use series codes like "nist_sp", "nist_ir", etc.
        key_str = type_key.to_s
        examples = fixture_data["nist_#{key_str}"] ||
          fixture_data[key_str.to_s] ||
          []

        return examples if examples.any?

        # Try class name match
        class_name = klass.name&.split("::")&.last
        snake_name = class_name&.gsub(/([A-Z])/, '_\1')&.downcase&.sub(/^_/, "")
        fixture_data[snake_name] || []
      end
    end
  end
end
