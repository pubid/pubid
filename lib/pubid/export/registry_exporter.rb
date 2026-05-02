# frozen_string_literal: true

module Pubid
  module Export
    # Strategy for flavors using TYPED_STAGES_REGISTRY on the Scheme class
    # (BSI, CEN). These don't use per-class TYPED_STAGES but instead have
    # a centralized registry mapping type_code → typed stages.
    class RegistryExporter < FlavorExporter
      def export
        registry = extract_registry
        return nil if registry.empty?

        identifier_types = registry.group_by(&:type_code).map do |type_code, stages|
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

        FlavorResult.new(
          flavor: flavor,
          identifier_types: identifier_types,
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
    end
  end
end
