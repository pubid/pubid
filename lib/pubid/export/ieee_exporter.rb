# frozen_string_literal: true

module Pubid
  module Export
    # Strategy for IEEE, which has a unique Scheme without an `identifiers`
    # method. Instead, identifier classes are discovered from the Identifiers
    # module constant list.
    class IeeeExporter < FlavorExporter
      KEY_IDENTIFIER_CLASSES = %i[
        Standard ProjectDraftIdentifier Base RedlinedStandard
      ].freeze

      def export
        klasses = resolve_ieee_identifiers
        return nil if klasses.empty?

        all_stages = extract_ieee_stages

        identifier_types = klasses.map do |klass|
          info = extract_type_info(klass)

          # Only assign stages to the primary type (Standard)
          stages = (info[:key] == :std) ? all_stages : []

          IdentifierTypeResult.new(
            key: info[:key],
            title: info[:title],
            short: info[:short],
            abbr: info[:abbr],
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

      def resolve_ieee_identifiers
        identifiers_mod = scheme_module::Identifiers
        KEY_IDENTIFIER_CLASSES.filter_map do |name|
          identifiers_mod.const_get(name)
        rescue NameError
          nil
        end
      end

      def extract_ieee_stages
        return [] unless scheme_module.const_defined?(:TypedStages)

        scheme_module::TypedStages::TYPED_STAGES
      rescue NameError
        []
      end
    end
  end
end
