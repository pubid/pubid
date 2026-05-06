# frozen_string_literal: true

module Pubid
  module Export
    # Strategy for flavors using Lutaml::Model::Serializable as their Scheme
    # (ETSI, Plateau). These have identifier classes in the Identifiers module
    # that may not have def self.type.
    class DataClassExporter < FlavorExporter
      def export
        klasses = resolve_identifier_classes_from_module
        return nil if klasses.empty?

        fixture_data = fixture_examples

        identifier_types = klasses.map do |klass|
          info = extract_type_info(klass)
          type_key = info[:key]
          examples = fixture_data[type_key] || fixture_data[type_key.to_s] || []

          IdentifierTypeResult.new(
            key: info[:key],
            title: info[:title],
            short: info[:short],
            abbr: info[:abbr],
            typed_stages: [],
            examples: examples,
          )
        end

        scheme = scheme_class
        attrs = scheme&.methods.include?(:attributes) ? scheme.attributes.keys.map(&:to_s) : []

        FlavorResult.new(
          flavor: flavor,
          identifier_types: identifier_types,
          attributes: attrs,
        )
      end

      private

      def resolve_identifier_classes_from_module
        mod = scheme_module
        return [] unless mod

        idents_mod = mod.const_get(:Identifiers)
        skip = %w[Base Supplement]

        idents_mod.constants.filter_map do |c|
          klass = begin; idents_mod.const_get(c); rescue NameError; next; end
          next unless klass.is_a?(Class)
          next if skip.include?(klass.name&.split("::")&.last)
          klass
        end
      end
    end
  end
end
