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

        # Handle FRAG as special fragment notation
        return nil if typed_stage_string == "FRAG"

        @scheme.locate_typed_stage_by_abbr(typed_stage_string)
      end

      def locate_identifier_klass(parsed_hash)
        # Check for working programme
        if parsed_hash[:wp_stage]
          require_relative 'identifiers/working_document'
          return Identifiers::WorkingDocument
        end

        # Check for working document
        if parsed_hash[:technical_committee] && parsed_hash[:wd_number]
          require_relative 'identifiers/working_document'
          return Identifiers::WorkingDocument
        end

        # Check the `:type_with_stage` to determine the identifier class
        # :type_with_stage will be nil if it is an IS.
        typed_stage = locate_typed_stage(parsed_hash[:type_with_stage])

        @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
      end

      def build(parsed_hash)
        # Extract FRAG/FRAGC indicator if present
        is_fragment = parsed_hash[:type_with_stage] == "FRAG" || parsed_hash[:type_with_stage] == "FRAGC"
        fragment_number = nil
        fragment_edition = nil

        if is_fragment
          # For FRAG/FRAGC, we need to build the base Amendment/Corrigendum
          # then wrap it with FragmentIdentifier
          if parsed_hash[:number_with_part]
            fragment_number = parsed_hash[:number_with_part].to_s
          end

          # Extract edition for fragment
          fragment_edition = parsed_hash.delete(:edition)

          # Build the base identifier (Amendment/Corrigendum) directly
          if parsed_hash[:base_identifier]
            base_id = build(parsed_hash[:base_identifier])
            return wrap_with_fragment(base_id, fragment_number, fragment_edition)
          end
        end

        # Check for TRF with CISPR - build embedded identifier
        trf_org = parsed_hash.delete(:trf_org)
        if trf_org && parsed_hash[:number_with_part]
          # Build CISPR identifier without year
          cispr_number = parsed_hash.delete(:number_with_part)
          cispr_id = Identifiers::InternationalStandard.new(
            publisher: Components::Publisher.new(body: "CISPR")
          )
          # Set number via cast
          number_components = cast(:number_with_part, cispr_number)
          number_components.each_pair do |k, v|
            cispr_id.send("#{k}=", v) if cispr_id.respond_to?("#{k}=")
          end
          parsed_hash[:cispr_identifier] = cispr_id
        end

        # Extract and store wrapper data before building
        consolidated_supplements_data = parsed_hash.delete(:consolidated_supplements)
        vap_suffix_data = parsed_hash.delete(:vap_suffix)
        sheet_number_data = parsed_hash.delete(:sheet_number)
        sheet_year_data = parsed_hash.delete(:sheet_year)

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
            # the realized component is an Identifier class to be added to a Combined Identifier
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

        # Detect rendering style from parsed abbreviation
        if identifier.respond_to?(:rendering_style=) && identifier.respond_to?(:typed_stage) && identifier.typed_stage
          require_relative 'rendering_style'
          ts = identifier.typed_stage

          # Detect IEC format from parsed abbreviation
          # IEC uses space to indicate long form: "Amd 1", "Cor 1"
          # No space indicates short form: "AMD1", "COR1"
          stage_format_long = if ts.long_abbr && ts.original_abbr && ts.original_abbr.include?(" ")
            true  # Long form has space: "Amd 1", "Cor 1"
          elsif ts.short_abbr && ts.original_abbr && !ts.original_abbr.include?(" ")
            false  # Short form: "AMD1", "COR1", "CDV", "FDIS"
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

        # After building base identifier, apply wrappers
        identifier = wrap_with_sheet(identifier, sheet_number_data, sheet_year_data) if sheet_number_data
        identifier = wrap_with_consolidated(identifier, consolidated_supplements_data) if consolidated_supplements_data
        identifier = wrap_with_vap(identifier, vap_suffix_data) if vap_suffix_data

        identifier
      end

      # Wrap identifier with FragmentIdentifier for /FRAGN notation
      def wrap_with_fragment(base_identifier, fragment_number, edition_data = nil)
        require_relative 'identifiers/fragment_identifier'

        fragment = Identifiers::FragmentIdentifier.new(
          base_identifier: base_identifier,
          fragment_number: fragment_number
        )

        # Set edition if provided
        if edition_data
          fragment.edition = cast(:edition, edition_data)
        end

        fragment
      end

      # Wrap identifier with SheetIdentifier for /N:YEAR notation
      def wrap_with_sheet(base_identifier, sheet_number, sheet_year)
        require_relative 'identifiers/sheet_identifier'

        Identifiers::SheetIdentifier.new(
          base_identifier: base_identifier,
          sheet_number: sheet_number.to_s,
          year: sheet_year.to_s
        )
      end

      # Wrap identifier with ConsolidatedIdentifier for +AMD chains
      def wrap_with_consolidated(base_identifier, supplements_data)
        require_relative 'identifiers/consolidated_identifier'
        require_relative 'identifiers/amendment'
        require_relative 'identifiers/corrigendum'

        supplements = supplements_data.map do |supp|
          type = supp[:supplement_type].to_s
          number = supp[:supplement_number].to_s
          year = supp[:supplement_year].to_s

          if type == "AMD"
            Identifiers::Amendment.new(
              number: Components::Code.new(value: number),
              date: PubidNew::Components::Date.new(year: year)
            )
          elsif type == "COR"
            Identifiers::Corrigendum.new(
              number: Components::Code.new(value: number),
              date: PubidNew::Components::Date.new(year: year)
            )
          end
        end.compact

        Identifiers::ConsolidatedIdentifier.new(
          identifiers: [base_identifier] + supplements
        )
      end

      # Wrap identifier with VapIdentifier for CSV/CMV/RLV/SER suffix
      def wrap_with_vap(base_identifier, vap_suffix_data)
        require_relative 'identifiers/vap_identifier'
        require_relative 'identifiers/consolidated_identifier'
        require_relative 'components/vap_suffix'

        vap_suffix = Components::VapSuffix.new(code: vap_suffix_data.to_s)

        # Extract edition - need to go deep for ConsolidatedIdentifier
        edition = nil
        if base_identifier.is_a?(Identifiers::ConsolidatedIdentifier)
          # Edition is on the first identifier (base document)
          edition = base_identifier.identifiers.first.edition if base_identifier.identifiers.first.respond_to?(:edition)
          # Clear it from base document
          base_identifier.identifiers.first.edition = nil if base_identifier.identifiers.first.respond_to?(:edition=)
        elsif base_identifier.respond_to?(:edition)
          edition = base_identifier.edition
          # Clear edition from base identifier since it moves to VAP level
          base_identifier.edition = nil if base_identifier.respond_to?(:edition=)
        end

        Identifiers::VapIdentifier.new(
          base_identifier: base_identifier,
          vap_suffix: vap_suffix,
          edition: edition
        )
      end

      # Convert roman numeral to integer
      def convert_roman_to_integer(roman_numeral)
        return roman_numeral unless roman_numeral.to_s.match?(/^[IVXLCDM]+$/i)

        # Don't convert single X - it's often used as a literal character in part numbers
        return roman_numeral if roman_numeral.to_s.upcase == "X"

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

        when :technical_committee, :wd_number, :wd_stage, :wd_language, :wp_stage, :wp_type
          # Working document/programme fields - just return as string
          value.to_s

        when :cispr_identifier
          # CISPR identifier object for TRF
          value

        when :number
          # Plain number for sub-org identifiers (CA, IECQ CS, IECQ OD)
          # Just return as Code component
          { number: Components::Code.new(value: value.to_s) }

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
          # Skip FRAG as it's handled specially
          return nil if value == "FRAG"

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
            PubidNew::Components::Date.new(year: year, month: month || nil)
          elsif value.is_a?(Integer) || value.is_a?(String) && value.match?(/^\d{4}$/)
            # If it's just a year, "2005"
            PubidNew::Components::Date.new(year: value)
          else
            raise ArgumentError, "Invalid date format: #{value.inspect}"
          end

        when :edition
          PubidNew::Components::Edition.new(number: value)

        when :languages
          # Can be: :languages=>"E/F/R" or: :languages=>"en,fr,ru"
          value = value.to_s.gsub("/", ",")

          value.split(",").map do |lang|
            # We need to convert these into 2 char language codes
            lang = lang.strip
            lang = LANG_CHAR_MAP[lang] if lang.length == 1
            PubidNew::Components::Language.new(code: lang)
          end

        when :all_parts
          PubidNew::Components::Locality.new(all_parts: true)

        when :database
          # Database flag - return true if DB suffix present
          true

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