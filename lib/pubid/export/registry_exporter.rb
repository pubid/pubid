# frozen_string_literal: true

require "set"

module Pubid
  module Export
    # Strategy for flavors using TYPED_STAGES_REGISTRY on the Scheme class
    # (BSI, CEN). These don't use per-class TYPED_STAGES but instead have
    # a centralized registry mapping type_code → typed stages.
    class RegistryExporter < FlavorExporter
      def export
        registry = extract_registry
        return nil if registry.empty?

        registry_keys = Set.new

        identifier_types = registry.group_by(&:type_code).map do |type_code, stages|
          registry_keys << type_code.to_s
          primary = stages.first
          IdentifierTypeResult.new(
            key: type_code,
            title: primary.name,
            short: nil,
            abbr: primary.abbr,
            typed_stages: stages,
            examples: [],
          )
        end

        # Supplement with typed classes not in the registry
        additional = discover_additional_from_identifiers(registry_keys)
        identifier_types.concat(additional)

        FlavorResult.new(
          flavor: flavor,
          identifier_types: identifier_types,
          wrapper_types: extract_wrapper_types,
          attributes: [],
        )
      end

      private

      def extract_registry
        scheme = scheme_class
        return [] unless scheme

        if scheme.const_defined?(:TYPED_STAGES_REGISTRY)
          scheme.const_get(:TYPED_STAGES_REGISTRY)
        else
          []
        end
      end

      def discover_additional_from_identifiers(known_keys)
        mod = scheme_module
        return [] unless mod

        idents_mod = mod.const_get(:Identifiers)

        idents_mod.constants.filter_map do |c|
          klass = idents_mod.const_get(c)
        rescue NameError
          next
        else
          next unless klass.is_a?(Class)

          begin
            type_info = klass.respond_to?(:type) ? klass.type : nil
            next unless type_info && type_info[:key]
          rescue NotImplementedError
            next
          end

          key_str = type_info[:key].to_s
          next if known_keys.include?(key_str)

          known_keys << key_str
          IdentifierTypeResult.new(
            key: type_info[:key],
            title: type_info[:title],
            short: type_info[:short],
            abbr: [],
            typed_stages: [],
            examples: [],
          )
        end
      end
    end
  end
end
