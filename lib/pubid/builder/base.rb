# frozen_string_literal: true

module Pubid
  module Builder
    # Base class for all flavor-specific builders.
    #
    # Provides the shared build loop that converts parsed data into identifier
    # objects. Flavors subclass and override:
    # - +select_class(data)+ to dispatch by data shape (default returns
    #   +default_identifier_class+).
    # - +cast(key, value)+ to transform raw parsed values into components.
    # - +handle_key(identifier, key, value)+ for non-attribute side effects.
    #
    # The build loop:
    # 1. Flattens array-of-hashes input (from Parslet transforms)
    # 2. Asks +select_class(data)+ for the identifier class
    # 3. Iterates each key-value pair
    # 4. Calls +cast(key, value)+ to convert raw values to component objects
    # 5. Assigns the result to the identifier via setter
    # 6. Silently skips unknown attributes
    class Base
      attr_reader :identifier

      def initialize(identifier_class = nil)
        @identifier_class = identifier_class
      end

      def build(data)
        data = flatten_array(data) if data.is_a?(Array)
        identifier_class = @identifier_class || select_class(data)
        identifier = identifier_class.new
        assign_attributes(identifier, data)
        identifier
      end

      private

      # Override in subclasses to dispatch to a specific identifier class
      # based on the shape of the parsed data (type code, supplement marker,
      # etc.). Defaults to +default_identifier_class+.
      def select_class(_data)
        default_identifier_class
      end

      # Override in subclasses to convert raw parsed values to component objects.
      # Return a Hash to assign multiple attributes, or a single value.
      # Return nil to skip the assignment.
      def cast(_key, value)
        value
      end

      def default_identifier_class
        raise NotImplementedError,
              "#{self.class} must implement default_identifier_class"
      end

      def flatten_array(data)
        data.each_with_object({}) do |h, acc|
          acc.merge!(h)
        end
      end

      def assign_attributes(identifier, data)
        attrs = identifier.class.attributes
        data.each_pair do |key, value|
          realized = cast(key.to_sym, value)
          next if realized.nil?

          next if handle_key(identifier, key, realized)

          if realized.is_a?(Hash)
            realized.each_pair do |k, v|
              setter = "#{k}="
              identifier.public_send(setter, v) if attrs.key?(k.to_sym)
            end
          else
            setter = "#{key}="
            identifier.public_send(setter, realized) if attrs.key?(key.to_sym)
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
        "L" => 50, "C" => 100, "D" => 500, "M" => 1000
      }.freeze

      def locate_typed_stage(typed_stage_string)
        raise NotImplementedError,
              "#{self.class} must implement locate_typed_stage " \
              "(rely on the flavor module's locate_stage method)"
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
        if value.match?(/^\d{4}(-\d{2}){0,2}$/)
          year, month, day = value.split("-")
          Pubid::Components::Date.new(year: year,
                                       month: month || nil,
                                       day: day || nil)
        elsif value.is_a?(Integer) || (value.is_a?(String) && value.match?(/^\d{4}$/))
          Pubid::Components::Date.new(year: value)
        else
          raise ArgumentError, "Invalid date format: #{value.inspect}"
        end
      end

      # Splits a compound document number ("1234", "1234-1", "1234-1-2")
      # into number/part/subpart Code components. Flavor-specific dash/slash
      # normalization lives in +normalize_number_with_part+; legacy year
      # extraction (e.g. ISO "4037-1979") lives in +extract_legacy_year+.
      def parse_number_with_part(value, code_class:)
        normalized = normalize_number_with_part(value)
        parts = normalized.split("-").reject(&:empty?)
        number = parts.shift
        part = parts.shift&.strip
        subpart = parts.any? ? parts.join("-") : nil

        legacy = extract_legacy_year(number, part, code_class)
        return legacy if legacy

        part = convert_roman_to_integer(part) if part

        code_hash = { number: code_class.new(value: number) }
        code_hash[:part] = code_class.new(value: part) if part
        code_hash[:subpart] = code_class.new(value: subpart) if subpart
        code_hash
      end

      # Hook: normalize the raw number_with_part string before splitting.
      # Override in subclasses for flavor-specific dash/slash/space handling.
      def normalize_number_with_part(value)
        value.to_s
      end

      # Hook: detect a year masquerading as a part (e.g. "4037-1979") and
      # return a number+date hash, or nil to continue normal splitting.
      def extract_legacy_year(_number, _part, _code_class)
        nil
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
