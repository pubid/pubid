# frozen_string_literal: true

module Pubid
  module Ansi
    # Builder for ANSI identifiers
    class Builder
      def initialize(scheme)
        @scheme = scheme
      end

      def build(parsed_hash)
        identifier = Identifiers::Standard.new

        parsed_hash.each_pair do |key, value|
          realized_components = cast(key.to_sym, value)
          next if realized_components.nil?

          case realized_components
          when Hash
            realized_components.each_pair do |sub_key, sub_value|
              if identifier.respond_to?("#{sub_key}=")
                identifier.send("#{sub_key}=",
                                sub_value)
              end
            end
          else
            if identifier.respond_to?("#{key}=")
              identifier.send("#{key}=",
                              realized_components)
            end
          end
        end

        identifier
      end

      def cast(type, value)
        case type
        when :publisher
          Components::Publisher.new(body: value)

        when :std_keyword
          # Return boolean indicating if "Std" was present
          !value.nil? && !value.empty?

        when :copublishers
          if value.nil? || value.empty?
            nil
          else
            value.map do |copublisher|
              Components::Publisher.new(body: copublisher[:copublisher])
            end
          end

        when :number_with_part
          # Parse ANSI numbers: X3.4, C63.4-2014, 9899, 802.3-2012
          # Keep dots as dots, only dashes become parts
          original_value = value.to_s

          # Split by dash to separate main number from parts
          main_and_parts = original_value.split("-")
          main_number = main_and_parts[0] # X3.4, C63.4, 9899, 802.3
          part_number = main_and_parts[1] # 1986, 2014, 2012, or nil

          {
            number: Components::Code.new(value: main_number),
            part: part_number ? Components::Code.new(value: part_number) : nil,
          }.compact

        when :date
          Components::Date.new(year: value.to_s)

        when :languages
          value.to_s.split(",").map do |lang|
            Components::Language.new(code: lang.strip)
          end

        else
          raise ArgumentError, "Unknown parameter type: #{type}"
        end
      end
    end
  end
end
