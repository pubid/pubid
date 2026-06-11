# frozen_string_literal: true

module Pubid
  module Jis
    # Base class for single (non-supplement) JIS identifiers
    # Includes: JapaneseIndustrialStandard, TechnicalReport, TechnicalSpecification
    class SingleIdentifier < Identifier
      # Type prefix to identifier class mapping
      TYPE_CLASSES = {
        "TR" => "TechnicalReport",
        "TS" => "TechnicalSpecification",
        nil => "JapaneseIndustrialStandard", # Default
      }.freeze

      # Determine identifier class from type prefix
      def self.identifier_class_for_type(type)
        class_name = TYPE_CLASSES[type]
        return nil unless class_name

        Identifiers.const_get(class_name)
      end

      def to_s(with_publisher: true, **opts)
        @with_publisher = with_publisher
        render(format: :human, **opts)
      end
    end
  end
end
