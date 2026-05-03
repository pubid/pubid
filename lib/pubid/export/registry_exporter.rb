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

        known_website_keys = Set.new

        identifier_types = registry.group_by(&:type_code).map do |type_code, stages|
          wkey = resolve_website_key(type_code).to_s
          known_website_keys << wkey
          primary = stages.first
          IdentifierTypeResult.new(
            key: wkey,
            title: primary.name,
            short: nil,
            abbr: primary.abbr,
            typed_stages: stages,
            examples: [],
          )
        end

        # Supplement with typed classes not in the registry
        additional = discover_additional_from_identifiers(known_website_keys)
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
        skip = %w[Base]

        idents_mod.constants.filter_map do |c|
          klass = idents_mod.const_get(c)
        rescue NameError
          next
        else
          next unless klass.is_a?(Class)
          next if skip.include?(klass.name&.split("::")&.last)

          info = extract_type_info(klass)
          next unless info[:key]

          website_key = info[:key].to_s
          next if known_keys.include?(website_key)

          known_keys << website_key
          IdentifierTypeResult.new(
            key: website_key,
            title: info[:title],
            short: info[:short],
            abbr: [],
            typed_stages: [],
            examples: [],
          )
        end
      end
    end
  end
end
