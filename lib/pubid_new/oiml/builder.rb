# frozen_string_literal: true

require_relative "components/code"

module PubidNew
  module Oiml
    class Builder
      # Type to identifier class mapping (MECE)
      TYPE_CLASS_MAP = {
        "B" => "BasicPublication",
        "D" => "Document",
        "E" => "ExpertReport",
        "G" => "Guide",
        "R" => "Recommendation",
        "S" => "SeminarReport",
        "V" => "Vocabulary"
      }.freeze

      def build(parsed_hash)
        # Determine identifier class from type
        type = parsed_hash[:type].to_s
        class_name = TYPE_CLASS_MAP[type] || "Recommendation"  # Default to R
        identifier_class = Identifiers.const_get(class_name)

        identifier = identifier_class.new

        # Handle code (number-part-subpart) specially
        if parsed_hash[:number] || parsed_hash[:part] || parsed_hash[:subpart]
          code_attrs = {}
          code_attrs[:number] = parsed_hash[:number].to_s if parsed_hash[:number]
          code_attrs[:part] = parsed_hash[:part].to_s if parsed_hash[:part]
          code_attrs[:subpart] = parsed_hash[:subpart].to_s if parsed_hash[:subpart]
          identifier.code = Components::Code.new(**code_attrs)
        end

        # Handle other attributes
        identifier.publisher = parsed_hash[:publisher].to_s if parsed_hash[:publisher]

        # Handle year -> date conversion
        if parsed_hash[:year]
          identifier.date = PubidNew::Components::Date.new(year: parsed_hash[:year].to_s)
        end

        # Handle stage attributes
        identifier.stage = parsed_hash[:stage].to_s if parsed_hash[:stage]
        identifier.iteration = parsed_hash[:iteration].to_s if parsed_hash[:iteration]

        # Handle language
        identifier.language = parsed_hash[:language].to_s if parsed_hash[:language]

        identifier
      end
    end
  end
end