require_relative "../components/publisher"
require_relative "../components/code"
require_relative "../components/edition"

module PubidNew
  module Ccsds
    class Builder
      def initialize(scheme)
        @scheme = scheme
        self
      end

      def locate_typed_stage(typed_stage_string)
        # CCSDS only has one type (base document)
        @scheme.locate_typed_stage_by_abbr("")
      end

      def locate_identifier_klass(parsed_hash)
        # Check if it's a corrigendum
        if parsed_hash[:base_identifier] && parsed_hash[:corrigendum_number]
          return Identifiers::Corrigendum
        end

        # Otherwise it's a base document
        Identifiers::Base
      end

      def build(parsed_hash)
        identifier = locate_identifier_klass(parsed_hash).new

        parsed_hash.each_pair do |key, value|
          realized_components = cast(key.to_sym, value)

          next if realized_components.nil?

          # Map corrigendum_number to number for supplements
          mapped_key = (key == :corrigendum_number) ? :number : key

          case realized_components
          when Hash
            realized_components.each_pair do |sub_key, sub_value|
              identifier.send("#{sub_key}=", sub_value) if identifier.respond_to?("#{sub_key}=")
            end
          else
            identifier.send("#{mapped_key}=", realized_components) if identifier.respond_to?("#{mapped_key}=")
          end
        end

        identifier
      end

      def cast(type, value)
        case type
        when :base_identifier
          build(value)

        when :series, :number, :part, :book_color
          Components::Code.new(value: value.to_s)

        when :corrigendum_number
          # Map corrigendum_number to number for the supplement
          Components::Code.new(value: value.to_s)

        when :edition
          # Edition can be "1" or "1.1"
          Components::Edition.new(number: value.to_s)

        when :retired
          # Presence of retired marker means true
          true

        when :language
          Components::Language.new(code: value.to_s)

        else
          nil
        end
      end
    end
  end
end