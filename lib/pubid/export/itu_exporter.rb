# frozen_string_literal: true

module Pubid
  module Export
    # Strategy for ITU, which uses a transform/model pattern without
    # traditional identifier classes or TYPED_STAGES.
    class ItuExporter < FlavorExporter
      def export
        scheme = scheme_class
        return nil unless scheme

        attrs = extract_serializable_attributes(scheme)

        FlavorResult.new(
          flavor: flavor,
          identifier_types: itu_identifier_types,
          attributes: extract_attribute_names(scheme),
        )
      end

      private

      def extract_serializable_attributes(klass)
        return {} unless klass.respond_to?(:model_attributes)
        klass.model_attributes
      rescue NoMethodError
        {}
      end

      def extract_attribute_names(scheme)
        return [] unless scheme.respond_to?(:model_class)
        model = scheme.model_class
        return [] unless model && model.respond_to?(:model_attributes)
        model.model_attributes.keys.map(&:to_s)
      rescue NoMethodError, NameError
        []
      end

      def itu_identifier_types
        # ITU has sector-based types (Recommendation, Resolution, etc.)
        %w[recommendation resolution handbook].map do |type_name|
          IdentifierTypeResult.new(
            key: type_name,
            title: type_name.capitalize,
            short: nil,
            abbr: [type_name.capitalize],
            typed_stages: [],
            examples: [],
          )
        end
      end
    end
  end
end
