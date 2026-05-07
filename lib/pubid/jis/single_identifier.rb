# frozen_string_literal: true

module Pubid
  module Jis
    # Base class for single (non-supplement) JIS identifiers
    # Includes: JapaneseIndustrialStandard, TechnicalReport, TechnicalSpecification
    class SingleIdentifier < Identifiers::Base
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

      def to_s(with_publisher: true)
        parts = []
        parts << publisher if with_publisher
        parts << type_prefix if self.class.method_defined?(:type_prefix) && type_prefix
        result = parts.join(" ")
        result += " " if result.length.positive?
        result += code.to_s
        result += ":#{year}" if year
        result += "(#{language})" if language
        result += "（規格群）" if all_parts?
        result
      end
    end
  end
end
