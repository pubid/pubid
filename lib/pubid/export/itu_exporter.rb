# frozen_string_literal: true

module Pubid
  module Export
    # Strategy for ITU, which uses a transform/model pattern without
    # traditional identifier classes or TYPED_STAGES.
    class ItuExporter < FlavorExporter
      WEBSITE_KEY_OVERRIDES = {
        "special_publication" => "special_publication",
      }.freeze

      def export
        klasses = resolve_itu_identifiers
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

        FlavorResult.new(
          flavor: flavor,
          identifier_types: identifier_types,
          attributes: extract_attribute_names,
        )
      end

      private

      def resolve_itu_identifiers
        identifiers_mod = scheme_module::Identifiers
        skip = %w[Base]
        identifiers_mod.constants.filter_map do |c|
          klass = begin; identifiers_mod.const_get(c); rescue NameError; next; end
          next unless klass.is_a?(Class)
          next if skip.include?(klass.name&.split("::")&.last)
          klass
        end
      end

      def extract_attribute_names
        model = scheme_module::Identifier
        return [] unless model&.methods.include?(:model_attributes)
        model.model_attributes.keys.map(&:to_s)
      rescue NoMethodError, NameError
        []
      end
    end
  end
end
