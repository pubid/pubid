# frozen_string_literal: true

module Pubid
  module Builder
    # Base class for all flavor-specific builders.
    #
    # Provides the shared build loop that converts parsed data into identifier
    # objects. Flavors subclass and override only `cast` and optionally
    # `default_identifier_class`.
    #
    # The build loop:
    # 1. Flattens array-of-hashes input (from Parslet transforms)
    # 2. Iterates each key-value pair
    # 3. Calls `cast(key, value)` to convert raw values to component objects
    # 4. Assigns the result to the identifier via `send`
    # 5. Silently skips unknown attributes (rescue NoMethodError)
    class Base
      attr_reader :identifier

      def initialize(identifier_class = default_identifier_class)
        @identifier_class = identifier_class
      end

      def build(data)
        data = flatten_array(data) if data.is_a?(Array)
        identifier = @identifier_class.new
        assign_attributes(identifier, data)
        identifier
      end

      private

      # Override in subclasses to convert raw parsed values to component objects.
      # Return a Hash to assign multiple attributes, or a single value.
      # Return nil to skip the assignment.
      def cast(_key, value)
        value
      end

      def default_identifier_class
        raise NotImplementedError, "#{self.class} must implement default_identifier_class"
      end

      def flatten_array(data)
        data.each_with_object({}) do |h, acc|
          acc.merge!(h)
        end
      end

      def assign_attributes(identifier, data)
        data.each_pair do |key, value|
          realized = cast(key.to_sym, value)
          next if realized.nil?

          next if handle_key(identifier, key, realized)

          if realized.is_a?(Hash)
            realized.each_pair do |k, v|
              identifier.send("#{k}=", v)
            rescue NoMethodError
              nil
            end
          else
            begin
              identifier.send("#{key}=", realized)
            rescue NoMethodError
              nil
            end
          end
        end
      end

      def handle_key(_identifier, _key, _value)
        false
      end

      LANG_CHAR_MAP = {
        "R" => "ru",
        "F" => "fr",
        "E" => "en",
        "A" => "ar",
        "S" => "es",
        "D" => "de",
      }.freeze

      ROMAN_MAP = {
        "I" => 1, "V" => 5, "X" => 10,
        "L" => 50, "C" => 100, "D" => 500, "M" => 1000,
      }.freeze

      def locate_typed_stage(typed_stage_string)
        typed_stage_string = "" if typed_stage_string.nil?
        @scheme.locate_typed_stage_by_abbr(typed_stage_string)
      end

      def convert_roman_to_integer(roman_numeral)
        return roman_numeral unless roman_numeral.to_s.match?(/^[IVXLCDM]+$/i)

        result = 0
        prev_value = 0

        roman_numeral.to_s.upcase.chars.reverse.each do |char|
          value = ROMAN_MAP[char]
          if value < prev_value
            result -= value
          else
            result += value
          end
          prev_value = value
        end

        result.to_s
      end

      def parse_date(value)
        value = value.to_s
        if value.match?(/^\d{4}(-\d{2})?$/)
          year, month = value.split("-")
          Pubid::Components::Date.new(year: year, month: month || nil)
        elsif value.is_a?(Integer) || (value.is_a?(String) && value.match?(/^\d{4}$/))
          Pubid::Components::Date.new(year: value)
        else
          raise ArgumentError, "Invalid date format: #{value.inspect}"
        end
      end

      def parse_languages(value)
        original_value = value.to_s
        normalized_value = original_value.gsub("/", ",")
        normalized_value.split(",").map do |lang|
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
