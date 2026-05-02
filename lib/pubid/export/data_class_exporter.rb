# frozen_string_literal: true

module Pubid
  module Export
    # Strategy for flavors using Lutaml::Model::Serializable as their Scheme
    # (ETSI, Plateau). These don't have per-class identifier types with
    # TYPED_STAGES — the Scheme itself is the data model.
    class DataClassExporter < FlavorExporter
      def export
        scheme = scheme_class
        return nil unless scheme

        attrs = extract_serializable_attributes(scheme)
        type_attr = find_type_attribute(attrs, scheme)

        identifier_types = build_types_from_attribute(type_attr, scheme)

        FlavorResult.new(
          flavor: flavor,
          identifier_types: identifier_types,
          attributes: attrs.keys.map(&:to_s),
        )
      end

      private

      def extract_serializable_attributes(klass)
        return {} unless klass.respond_to?(:attributes)

        klass.attributes
      rescue NoMethodError
        {}
      end

      def find_type_attribute(attrs, _scheme)
        attrs[:type]
      end

      def build_types_from_attribute(type_attr, _scheme)
        return [] unless type_attr

        types = known_types_for_flavor
        types.map do |type_name|
          IdentifierTypeResult.new(
            key: type_name.downcase.gsub(/\s+/, "_"),
            title: type_name,
            short: nil,
            abbr: [type_name],
            typed_stages: [],
            examples: [],
          )
        end
      end

      def known_types_for_flavor
        case flavor.to_s
        when "etsi"
          %w[EN TS TR GS EG SR]
        when "plateau"
          %w[Handbook Technical\ Report]
        else
          []
        end
      end
    end
  end
end
