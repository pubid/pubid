# frozen_string_literal: true

require "set"

module Pubid
  module Export
    # Strategy for IEEE, which has identifier classes in the Identifiers module
    # without a Scheme.identifiers method.
    class IeeeExporter < FlavorExporter
      def export
        klasses = resolve_ieee_identifiers
        return nil if klasses.empty?

        fixture_data = fixture_examples
        seen_keys = Set.new

        identifier_types = klasses.filter_map do |klass|
          info = extract_type_info(klass)
          next if seen_keys.include?(info[:key])

          seen_keys << info[:key]

          type_key = info[:key]
          examples = match_ieee_examples(fixture_data, type_key, klass)

          IdentifierTypeResult.new(
            key: info[:key],
            title: info[:title],
            short: info[:short],
            abbr: info[:abbr],
            typed_stages: [],
            examples: examples,
          )
        end

        FlavorResult.new(
          flavor: flavor,
          identifier_types: identifier_types,
          attributes: [],
        )
      end

      private

      def resolve_ieee_identifiers
        identifiers_mod = scheme_module::Identifiers
        skip = %w[Base Supplement]
        klasses = []
        collect_classes(identifiers_mod, skip, klasses)
        klasses
      end

      def collect_classes(mod, skip, result)
        mod.constants.each do |c|
          const = begin; mod.const_get(c); rescue NameError; next; end
          if const.is_a?(Module) && !const.is_a?(Class)
            collect_classes(const, skip, result)
          elsif const.is_a?(Class)
            next if skip.include?(const.name&.split("::")&.last)

            result << const
          end
        end
      end

      def match_ieee_examples(fixture_data, type_key, klass)
        # Try direct key match
        examples = fixture_data[type_key] || fixture_data[type_key.to_s] || []
        return examples if examples.any?

        # Try class name match
        class_name = klass.name&.split("::")&.last
        snake_name = class_name&.gsub(/([A-Z])/, '_\1')&.downcase&.sub(/^_/, "")
        fixture_data[snake_name] || []
      end
    end
  end
end
