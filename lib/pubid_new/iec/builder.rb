require_relative "../components/publisher"
require_relative "../components/code"
require_relative "../components/date"

module PubidNew
  module Iec
    class Builder
      LANG_CHAR_MAP = {
        "R" => "ru",
        "F" => "fr",
        "E" => "en",
        "A" => "ar",
        "S" => "es",
        "D" => "de",
      }.freeze

      def initialize(scheme)
        @scheme = scheme
        self
      end

      def locate_typed_stage(typed_stage_string)
        # if IS, then typed_stage_string will be nil (Parslet gives us ""@4 which somehow becomes nil here)
        typed_stage_string = "" if typed_stage_string.nil?

        @scheme.locate_typed_stage_by_abbr(typed_stage_string)
      end

      def locate_identifier_klass(parsed_hash)
        # Check the `:type_with_stage` to determine the identifier class
        # :type_with_stage will be nil if it is an IS.
        typed_stage = locate_typed_stage(parsed_hash[:type_with_stage])

        @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
      end

      def build(parsed_hash)
        # Instantiate the identifier based on the typed stage
        identifier = locate_identifier_klass(parsed_hash).new

        # For French GUIDE entries: "Guide IEC 51:1999"
        if type_with_stage_fr = parsed_hash.delete(:type_with_stage_fr)
          parsed_hash[:type_with_stage] = type_with_stage_fr
        end

        parsed_hash.each_pair do |key, value|
          realized_components = cast(key.to_sym, value)

          next if realized_components.nil?

          if key == :joint_identifier
            # the realized component is an Identifier class to be added to a CombinedIdentifier
            identifier.additional_identifiers ||= []
            identifier.additional_identifiers << realized_components
            next
          end

          case realized_components
          when Hash
            realized_components.each_pair do |sub_key, sub_value|
              identifier.send("#{sub_key}=", sub_value) if identifier.respond_to?("#{sub_key}=")
            end
          else
            identifier.send("#{key}=", realized_components) if identifier.respond_to?("#{key}=")
          end
        end

        identifier
      end

      # Convert roman numeral to integer
      def convert_roman_to_integer(roman_numeral)
        return roman_numeral unless roman_numeral.to_s.match?(/^[IVXLCDM]+$/i)

        roman_to_int_map = {
          "I" => 1,
          "V" => 5,
          "X" => 10,
          "L" => 50,
          "C" => 100,
          "D" => 500,
          "M" => 1000,
        }

        result = 0
        prev_value = 0

        roman_numeral.to_s.upcase.chars.reverse.each do |char|
          value = roman_to_int_map[char]
          if value < prev_value
            result -= value
          else
            result += value
          end
          prev_value = value
        end

        result.to_s
      end

      def cast(type, value)
        case type
        when :base_identifier
          # If it has a base identifier, we need to build a supplement
          # We assume that the base identifier is already a valid Identifier object
          build(value)

        when :publisher
          Components::Publisher.new(body: value)

        when :copublishers
          if value.nil? || value.empty?
            nil
          else
            value.map do |copublisher|
              Components::Publisher.new(body: copublisher[:copublisher])
            end
          end

        when :number_with_part
          # "60038" (no part)
          # or "60038-1" ('1' is part)
          # or "60038-1-2" ('1' is part, '2' is subpart)
          # or "29110-5-1-1" ('5' is part, '1-1' is subpart)

          # Split the number into parts
          normalized_value = value.to_s.tr(Parser::DASH_CHARS.join, "-")

          parts = normalized_value.split("-")
          number = parts.shift # The first part is always the number
          part = parts.shift # The second part is the part, if present
          subpart = parts.any? ? parts.join("-") : nil # The remaining parts form the subpart, if present

          part = convert_roman_to_integer(part)

          code_hash = { number: Components::Code.new(value: number) }

          if part
            code_hash[:part] = Components::Code.new(value: part)
          end

          if subpart
            code_hash[:subpart] = Components::Code.new(value: subpart)
          end

          code_hash

        when :type_with_stage
          # "WD"
          # "TS"
          # "Guide"
          iteration = value.to_s.match(/(\d+)$/)
          value = value.to_s.sub(iteration.to_s, "")
          typed_stage = locate_typed_stage(value || "")

          ## IMPORTANT!!
          # Always use TypedStage in an Identifier or separate Type and Stage.
          {
            stage: typed_stage.to_stage,
            type: typed_stage.to_type,
            typed_stage: typed_stage,
          }
        when :stage_iteration
          # "1" or "2"
          Components::Code.new(value: value.to_s)

        when :date
          value = value.to_s
          # If there is month, "2005-12"
          if value.match?(/^\d{4}(-\d{2})?$/)
            year, month = value.split("-")
            Components::Date.new(year: year, month: month || nil)
          elsif value.is_a?(Integer) || value.is_a?(String) && value.match?(/^\d{4}$/)
            # If it's just a year, "2005"
            Components::Date.new(year: value)
          else
            raise ArgumentError, "Invalid date format: #{value.inspect}"
          end

        when :edition
          Components::Edition.new(number: value)

        when :languages
          # Can be: :languages=>"E/F/R" or: :languages=>"en,fr,ru"
          value = value.to_s.gsub("/", ",")

          value.split(",").map do |lang|
            # We need to convert these into 2 char language codes
            lang = lang.strip
            lang = LANG_CHAR_MAP[lang] if lang.length == 1
            Components::Language.new(code: lang)
          end

        when :all_parts
          Components::Locality.new(all_parts: true)

        # Handle joint identifiers with ISO
        when :joint_identifier
          case value[:publisher]
          when "ISO"
            require_relative '../iso/builder'
            Iso::Builder.new(Iso::Scheme).build(value)
          end

        else
          raise ArgumentError, "Unknown parameter type: #{type}"
        end
      end
    end
  end
end