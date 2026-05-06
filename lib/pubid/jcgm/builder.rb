# frozen_string_literal: true

module Pubid
  module Jcgm
    class Builder < Pubid::Builder::Base
      def initialize(scheme)
        @scheme = scheme
      end

      def locate_identifier_klass(parsed_hash)
        if parsed_hash[:base_identifier]
          return @scheme.locate_identifier_klass_by_type_code(:amendment)
        end

        if parsed_hash[:gum_number]
          return @scheme.locate_identifier_klass_by_type_code(:gum_guide)
        end

        typed_stage = locate_typed_stage(parsed_hash[:type_with_stage])
        @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
      end

      def build(parsed_hash)
        identifier = locate_identifier_klass(parsed_hash).new
        assign_attributes(identifier, parsed_hash)

        if identifier.methods.include?(:typed_stage) && identifier.typed_stage.nil?
          default_typed_stage = @scheme.locate_typed_stage_by_abbr("")
          identifier.typed_stage = default_typed_stage
          identifier.stage = default_typed_stage.to_stage if identifier.methods.include?(:stage=)
          identifier.type = default_typed_stage.to_type if identifier.methods.include?(:type=)
        end

        identifier
      end

      private

      def default_identifier_class
        Identifiers::Guide
      end

      def cast(type, value)
        case type
        when :base_identifier
          build(value)
        when :publisher
          Jcgm::Components::Publisher.new(publisher: value.to_s)
        when :number
          Pubid::Components::Code.new(value: value.to_s)
        when :gum_number
          Pubid::Components::Code.new(value: value.to_s)
        when :date
          date_str = value.to_s
          if date_str.include?("-")
            parts = date_str.split("-")
            Pubid::Components::Date.new(
              year: parts[0],
              month: parts[1],
              day: parts[2],
            )
          else
            Pubid::Components::Date.new(year: date_str)
          end
        when :iteration
          Pubid::Components::Code.new(value: value.to_s)
        when :type_with_stage
          typed_stage = locate_typed_stage(value.to_s)
          {
            stage: typed_stage.to_stage,
            type: typed_stage.to_type,
            typed_stage: typed_stage,
          }
        when :languages
          original_value = value.to_s
          langs = original_value.include?("/") ? original_value.split("/") : [original_value]
          langs.map do |lang|
            lang = lang.strip
            original_lang = lang
            lang = LANG_CHAR_MAP[lang] if lang.length == 1
            Pubid::Components::Language.new(code: lang,
                                            original_code: original_lang)
          end
        end
      end
    end
  end
end
