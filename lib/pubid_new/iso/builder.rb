require_relative "components/publisher"
require_relative "components/code"
require_relative "../components/date"
require_relative "../components/edition"
require_relative "../components/language"
require_relative "../components/locality"

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

        # If there are supplements, we need to use a BundledIdentifier
        # which takes `base_document` and `supplements`
        if parsed_hash[:supplements]
          return BundledIdentifier
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

        @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
      end

      def build(parsed_hash)
        # For ISO/R legacy format, split into publisher and type
        if parsed_hash[:iso_r_prefix]
          parsed_hash[:publisher] = "ISO"
          parsed_hash[:type_with_stage] = "R"
          parsed_hash.delete(:iso_r_prefix)
        end

        # Instantiate the identifier based on the typed stage
        identifier = locate_identifier_klass(parsed_hash).new

        # For French GUIDE entries: "Guide ISO/CEI 37:1995"
        if type_with_stage_fr = parsed_hash.delete(:type_with_stage_fr)
          parsed_hash[:type_with_stage] = type_with_stage_fr
        end

        # For DirectivesSupplement, rename :publisher to :supplement_publisher
        if identifier.is_a?(Identifiers::DirectivesSupplement) && parsed_hash[:publisher]
          parsed_hash[:supplement_publisher] = parsed_hash.delete(:publisher)
        end

        # Merge copublishers into publisher object
        if parsed_hash[:publisher] && parsed_hash[:copublishers]
          copublisher_strings = parsed_hash[:copublishers].map { |cp| cp[:copublisher] }
          parsed_hash[:publisher] = {
            publisher: parsed_hash[:publisher],
            copublisher:  copublisher_strings
          }
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

        # If typed_stage, stage, or type are still nil after building,
        # set them to the default International Standard values
        if identifier.respond_to?(:typed_stage) && identifier.typed_stage.nil?
          default_typed_stage = @scheme.locate_typed_stage_by_abbr("")
          identifier.typed_stage = default_typed_stage if identifier.respond_to?(:typed_stage=)
          identifier.stage = default_typed_stage.to_stage if identifier.respond_to?(:stage=)
          identifier.type = default_typed_stage.to_type if identifier.respond_to?(:type=)
        end

        # Detect rendering style from parsed abbreviation
        if identifier.respond_to?(:rendering_style=) && identifier.respond_to?(:typed_stage) && identifier.typed_stage
          require_relative 'rendering_style'
          ts = identifier.typed_stage

          # Detect stage format from parsed abbreviation
          stage_format_long = if ts.long_abbr && ts.original_abbr && ts.original_abbr.start_with?(ts.long_abbr)
            true  # Long form (starts with Amd, DAmd, FDAmd, Cor, DCor, FDCor)
          elsif ts.long_abbr && ts.original_abbr && ts.original_abbr.include?("Directives")
            # Special case for Directives: any form with "Directives" word is long form
            true  # "Directives Part", "Directives, Part", "Directives,"
          elsif ts.short_abbr && ts.original_abbr && ts.original_abbr.start_with?(ts.short_abbr)
            false  # Short form (starts with AMD, DAM, FDAM, COR, DCOR, FDCOR, DIR)
          else
            false  # Default to short/canonical
          end

          # Detect language code format from parsed languages
          with_language_code = if identifier.respond_to?(:languages) && identifier.languages&.any?
            # Check if original_code was single-char (E, F, R, A, S, D)
            first_lang = identifier.languages.first
            if first_lang.respond_to?(:original_code) && first_lang.original_code && first_lang.original_code.length == 1
              :single
            else
              :iso  # 2-char codes (en, fr, ru, ar, es, de)
            end
          else
            :none
          end

          # with_date is always true for base identifiers (show the date if present)
          # Only supplements might have undated references
          with_date = true

          # Create custom rendering style based on parsed format
          identifier.rendering_style = RenderingStyle.new(
            with_language_code: with_language_code,
            stage_format_long: stage_format_long,
            with_date: with_date
          )
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

          # If there is a base_identifier, and it has a joint_identifier, we need to use a CombinedIdentifier.

        when :publisher, :directives_supplement_body, :supplement_publisher
          # value can be either a string OR a hash with publisher + copublisher
          if value.is_a?(Hash)
            PubidNew::Iso::Components::Publisher.new(
              publisher: value[:publisher],
              copublisher: value[:copublisher]
            )
          else
            PubidNew::Iso::Components::Publisher.new(publisher: value)
          end

        when :copublishers
          # Copublishers already merged into publisher
          # Create array of Publisher objects for identifier.copublishers attribute
          if value.nil? || value.empty?
            nil
          else
            value.map do |copublisher|
              PubidNew::Iso::Components::Publisher.new(publisher: copublisher[:copublisher])
            end
          end

        when :number_with_part
          # "1234" (no part)
          # or "1234-1" ('1' is part)
          # or "1234-1-2" ('1' is part, '2' is subpart)
          # or "29110-5-1-1" ('5' is part, '1-1' is subpart)
          # or "105/F" ('F' is part)
          # or "5843/6" ('6' is part)
          # LEGACY: "4037-1979" (number-year, year should become date)

          # Split the number into parts
          normalized_value = value.to_s.tr(Parser::DASH_CHARS.join + "/", "-")

          # for "1 IEC" ('IEC' is part) (in case of "ISO/IEC DIR 1 IEC")
          normalized_value.gsub!(" ", "-")

          parts = normalized_value.split("-").reject(&:empty?)
          number = parts.shift # The first part is always the number
          part = parts.shift&.strip # The second part is the part, if present
          subpart = parts.any? ? parts.join("-") : nil # The remaining parts form the subpart, if present

          # LEGACY FORMAT FIX: If "part" is a 4-digit year (1900-2099), move it to date field
          # This handles legacy formats like "ISO 4037-1979" where hyphen was used instead of colon
          if part&.match?(/^\d{4}$/)
            year_value = part.to_i
            # Only treat as year if in reasonable year range (excludes part numbers like "1751")
            if year_value >= 1900 && year_value <= 2099
              return {
                number: PubidNew::Iso::Components::Code.new(number: number),
                date: PubidNew::Components::Date.new(year: part)
              }
            end
          end

          part = convert_roman_to_integer(part)

          code_hash = { number: PubidNew::Iso::Components::Code.new(number: number) }

          if part
            code_hash[:part] = PubidNew::Iso::Components::Code.new(number: part)
          end

          if subpart
            code_hash[:subpart] = PubidNew::Iso::Components::Code.new(number: subpart)
          end

          code_hash

        when :directives_type
          # nothing to do here, just return nil
          nil

        when :type_with_stage
          # "WD"
          # "PAS"
          # "CD TR"
          original_value = value.to_s  # Store the original parsed value
          iteration = original_value.match(/(\d+)$/)
          normalized_value = original_value.sub(iteration.to_s, "")
          typed_stage = locate_typed_stage(normalized_value || "")

          # Create a copy with the original abbreviation preserved
          typed_stage_with_original = typed_stage.dup
          typed_stage_with_original.original_abbr = original_value.strip

          ##
          # Always use TypedStage in an Identifier or separate Type and Stage.
          {
            stage: typed_stage_with_original.to_stage,
            type: typed_stage_with_original.to_type,
            typed_stage: typed_stage_with_original,
          }
        when :stage_iteration
          # "1" or "2"
          PubidNew::Iso::Components::Code.new(number: value.to_s)

        when :date
          value = value.to_s
          # If there is month, "2005-12"
          if value.match?(/^\d{4}(-\d{2})?$/)
            year, month = value.split("-")
            PubidNew::Components::Date.new(year: year, month: month || nil)
          elsif value.is_a?(Integer) || value.is_a?(String) && value.match?(/^\d{4}$/)
            # If it's just a year, "2005"
            PubidNew::Components::Date.new(year: value)
          else
            raise ArgumentError, "Invalid date format: #{value.inspect}"
          end

        when :edition
          # value can be "Ed.2", "Ed 2", "ED1", "Edition 13", or just "Ed"
          original_text = value.to_s
          # Extract just the digit(s) for the number field
          number_string = original_text.match(/\d+/)&.to_s
          number_code = number_string ? PubidNew::Iso::Components::Code.new(number: number_string) : nil
          PubidNew::Components::Edition.new(number: number_code, original_text: original_text)

        when :languages
          # Can be: :languages=>"E/F/R" or: :languages=>"en,fr,ru"
          original_value = value.to_s
          normalized_value = original_value.gsub("/", ",")

          normalized_value.split(",").map.with_index do |lang, idx|
            # We need to convert these into 2 char language codes
            lang = lang.strip
            original_lang = lang  # Store original format before conversion
            lang = LANG_CHAR_MAP[lang] if lang.length == 1
            PubidNew::Components::Language.new(code: lang, original_code: original_lang)
          end

        when :all_parts
          PubidNew::Components::Locality.new(all_parts: true)

        # ISO 4214:2022 | IDF/RM 254:2022
        when :joint_identifier
          case value[:publisher]
          when "IDF"
            require_relative '../idf/builder'
            Idf::Builder.new(Idf::Scheme).build(value)
          end

        when :subgroup
          # Handle JTC 1 subgroup in directives (ISO/IEC JTC 1 DIR)
          # Store as a component for potential use in rendering
          PubidNew::Iso::Components::Code.new(number: value.to_s)

        when :supplements
          # Handle bundled supplements (+ operator)
          # Each supplement is a hash that needs to be built
          value.map { |supplement_hash| build(supplement_hash[:supplement]) }

        when :base_document
          # For bundled identifiers, build the base document
          build(value)

        else
          raise ArgumentError, "Unknown parameter type: #{type}"
        end
      end
    end
  end
end
