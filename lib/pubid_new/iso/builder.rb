require_relative "../components/publisher"
require_relative "../components/code"
require_relative "../components/date"

module PubidNew
  # Identifier that
  module Iso
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
        # If there is a joint_identifier, we need to use a CombinedIdentifier
        # which takes `base_identifier` and `additional_identifiers`
        if parsed_hash[:joint_identifier]
          return CombinedIdentifier
        end

        # Check the `:type_with_stage` to determine the identifier class
        # 1. :type_with_stage will be nil if:
        # a) It is an IS.
        # b) It is a Directive Supplements. The "SUP" keyword may be entirely missing, and hence nil. If the base type_with_stage is a directive, then if the type_with_stage is blank, it is a directive supplement.

        if parsed_hash[:type_with_stage].nil? && parsed_hash[:base_identifier] && parsed_hash[:base_identifier][:type_with_stage] == "DIR"
          # Directive Supplement without "SUP" keyword
          parsed_hash[:type_with_stage] = "SUP"
        end

        typed_stage = locate_typed_stage(parsed_hash[:type_with_stage])
        puts "Typed stage is #{typed_stage.inspect}"

        @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
      end

      def build(parsed_hash)
        puts "Building identifier from source: #{parsed_hash.inspect}"

        # Instantiate the identifier based on the typed stage
        identifier = locate_identifier_klass(parsed_hash).new

        puts "The identifier is #{identifier.class}" if identifier

        # For French GUIDE entries: "Guide ISO/CEI 37:1995"
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
            puts "Added joint identifier: #{realized_components.inspect}"
            next
          end

          puts "Setting #{key} with value: #{realized_components.inspect}"

          case realized_components
          when Hash
            realized_components.each_pair do |sub_key, sub_value|
              puts "Setting sub-component #{sub_key} with value: #{sub_value.inspect}"
              if identifier.respond_to?("#{sub_key}=")
                identifier.send("#{sub_key}=", sub_value)
              else
                puts "Warning: #{sub_key} is not a valid attribute for Identifier"
              end
            end
          else
            puts "Setting component #{key} with value: #{realized_components.inspect}"
            if identifier.respond_to?("#{key}=")
              identifier.send("#{key}=", realized_components)
            else
              puts "Warning: #{key} is not a valid attribute for Identifier"
            end
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
        puts "Casting #{type} with value: #{value.inspect}"

        case type
        when :base_identifier
          # If it has a base identifier, we need to build a supplement
          # We assume that the base identifier is already a valid Identifier object
          build(value)

          # If there is a base_identifier, and it has a joint_identifier, we need to use a CombinedIdentifier.

        when :publisher, :directives_supplement_body
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
          # "1234" (no part)
          # or "1234-1" ('1' is part)
          # or "1234-1-2" ('1' is part, '2' is subpart)
          # or "29110-5-1-1" ('5' is part, '1-1' is subpart)
          # or "105/F" ('F' is part)
          # or "5843/6" ('6' is part)

          # Split the number into parts
          normalized_value = value.to_s.tr(Parser::DASH_CHARS.join + "/", "-")

          # for "1 IEC" ('IEC' is part) (in case of "ISO/IEC DIR 1 IEC")
          normalized_value.gsub!(" ", "-")

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

        when :directives_type
          # nothing to do here, just return nil
          nil

        when :type_with_stage
          # "WD"
          # "PAS"
          # "CD TR"
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

        # ISO 4214:2022 | IDF/RM 254:2022
        when :joint_identifier
          case value[:publisher]
          when "IDF"
            require_relative '../idf/builder'
            Idf::Builder.new(Idf::Scheme).build(value)
          end
        else
          raise ArgumentError, "Joint identifier type not yet implemented: #{type}"
        end
      end
    end
  end
end
