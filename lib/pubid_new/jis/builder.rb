require_relative "../components/publisher"
require_relative "../components/code"
require_relative "../components/date"

module PubidNew
  module Jis
    class Builder
      def initialize(scheme)
        @scheme = scheme
        self
      end

      def locate_typed_stage(type_string)
        # Default to JIS if no type specified
        type_string = "JIS" if type_string.nil? || type_string.to_s.empty?
        
        @scheme.locate_typed_stage_by_abbr(type_string.to_s)
      end

      def locate_identifier_klass(parsed_hash)
        # Check for type_prefix (TR or TS)
        type_str = if parsed_hash[:type_prefix]
          parsed_hash[:type_prefix]
        else
          "JIS"
        end
        
        typed_stage = locate_typed_stage(type_str)
        @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
      end

      def build(parsed_hash)
        identifier = locate_identifier_klass(parsed_hash).new

        parsed_hash.each_pair do |key, value|
          realized_components = cast(key.to_sym, value)

          next if realized_components.nil?

          case realized_components
          when Hash
            # Spread hash components into identifier
            realized_components.each_pair do |sub_key, sub_value|
              identifier.send("#{sub_key}=", sub_value) if identifier.respond_to?("#{sub_key}=")
            end
          else
            # Direct assignment
            identifier.send("#{key}=", realized_components) if identifier.respond_to?("#{key}=")
          end
        end

        identifier
      end

      def cast(type, value)
        case type
        when :publisher
          Components::Publisher.new(body: value)

        when :series
          Components::Code.new(value: value)

        when :number
          Components::Code.new(value: value)

        when :part
          # Part can be "-1" or "-1-2" or "-2-1"
          # Remove leading dash and treat as full part string
          part_str = value.to_s.sub(/^-/, "")
          Components::Code.new(value: part_str)

        when :language
          Components::Code.new(value: value)

        when :type_prefix
          # "TR", "TS"
          typed_stage = locate_typed_stage(value.to_s)

          {
            type: typed_stage.to_type,
            typed_stage: typed_stage,
          }

        when :date
          value = value.to_s
          if value.match?(/^\d{4}$/)
            Components::Date.new(year: value)
          else
            raise ArgumentError, "Invalid date format: #{value.inspect}"
          end

        else
          # Don't process unknown keys
          nil
        end
      end
    end
  end
end