# frozen_string_literal: true

require_relative "components/publisher"
require_relative "../components/code"
require_relative "../components/date"
require_relative "../components/language"

module PubidNew
  module Jcgm
    class Builder
      LANG_CHAR_MAP = {
        "F" => "fr",
        "E" => "en",
        "R" => "ru",
      }.freeze

      def initialize(scheme)
        @scheme = scheme
        self
      end

      def locate_typed_stage(typed_stage_string)
        typed_stage_string = "" if typed_stage_string.nil?
        @scheme.locate_typed_stage_by_abbr(typed_stage_string)
      end

      def locate_identifier_klass(parsed_hash)
        # If there's a base_identifier, it's an amendment
        if parsed_hash[:base_identifier]
          return @scheme.locate_identifier_klass_by_type_code(:amendment)
        end

        # Check for GUM number to determine if it's a GumGuide
        if parsed_hash[:gum_number]
          return @scheme.locate_identifier_klass_by_type_code(:gum_guide)
        end

        # Otherwise it's a regular Guide
        typed_stage = locate_typed_stage(parsed_hash[:type_with_stage])
        @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
      end

      def build(parsed_hash)
        identifier = locate_identifier_klass(parsed_hash).new

        parsed_hash.each_pair do |key, value|
          realized_components = cast(key.to_sym, value)
          next if realized_components.nil?

          case realized_components
          when Hash
            realized_components.each_pair do |sub_key, sub_value|
              identifier.send("#{sub_key}=", sub_value) if identifier.respond_to?("#{sub_key}=")
            end
          else
            identifier.send("#{key}=", realized_components) if identifier.respond_to?("#{key}=")
          end
        end

        # Set default typed_stage if still nil
        if identifier.respond_to?(:typed_stage) && identifier.typed_stage.nil?
          default_typed_stage = @scheme.locate_typed_stage_by_abbr("")
          identifier.typed_stage = default_typed_stage
          identifier.stage = default_typed_stage.to_stage if identifier.respond_to?(:stage=)
          identifier.type = default_typed_stage.to_type if identifier.respond_to?(:type=)
        end

        identifier
      end

      def cast(type, value)
        case type
        when :base_identifier
          # Build the base identifier recursively
          build(value)

        when :publisher
          PubidNew::Jcgm::Components::Publisher.new(publisher: value.to_s)

        when :number
          PubidNew::Components::Code.new(value: value.to_s)

        when :gum_number
          # GUM number as Code component
          PubidNew::Components::Code.new(value: value.to_s)

        when :date
          # Can be YYYY or YYYY-MM-DD
          date_str = value.to_s
          if date_str.include?("-")
            # Full date: YYYY-MM-DD
            parts = date_str.split("-")
            PubidNew::Components::Date.new(
              year: parts[0],
              month: parts[1],
              day: parts[2]
            )
          else
            # Year only
            PubidNew::Components::Date.new(year: date_str)
          end

        when :iteration
          # Amendment number
          PubidNew::Components::Code.new(value: value.to_s)

        when :type_with_stage
          # For amendments
          typed_stage = locate_typed_stage(value.to_s)
          {
            stage: typed_stage.to_stage,
            type: typed_stage.to_type,
            typed_stage: typed_stage,
          }

        when :languages
          # Can be: "F", "E", "E/F", "F/E"
          original_value = value.to_s

          # Split on "/" if present
          langs = original_value.include?("/") ? original_value.split("/") : [original_value]

          langs.map do |lang|
            lang = lang.strip
            original_lang = lang
            # Convert single-char to 2-char code
            lang = LANG_CHAR_MAP[lang] if lang.length == 1
            PubidNew::Components::Language.new(code: lang, original_code: original_lang)
          end

        else
          nil
        end
      end
    end
  end
end