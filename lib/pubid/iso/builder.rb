# frozen_string_literal: true

module Pubid
  module Iso
    class Builder < Pubid::Builder::Base
      def initialize
        # No state needed: lookups are delegated to the Pubid::Iso module.
      end

      # Override the base implementation to avoid relying on @scheme.
      # @param typed_stage_string [String, nil]
      # @return [Pubid::Components::TypedStage, nil]
      def locate_typed_stage(typed_stage_string)
        Pubid::Iso.locate_stage(typed_stage_string.to_s)
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

        # TC documents are identified by the presence of tc_type
        if parsed_hash[:tc_type]
          return Identifiers::TcDocument
        end

        # An explicit document type (e.g. from a URN's `:tr:`/`:ts:` token) pins
        # the class regardless of the stage. The stage and type are separate URN
        # fields, but the stage is later folded into `:type_with_stage` (e.g.
        # "WDA" for 90.93), which would otherwise mis-resolve the class to the
        # stage's owning type (IS). Consume the hint here, before assign_attributes.
        if (doc_type = parsed_hash.delete(:document_type))
          type_stage = locate_typed_stage(doc_type)
          return Pubid::Iso.locate_type(type_stage.type_code) if type_stage
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

        Pubid::Iso.locate_type(typed_stage.type_code)
      end

      def build(parsed_hash)
        # For ISO/R legacy format, split into publisher and type
        if parsed_hash[:iso_r_prefix]
          parsed_hash[:publisher] = "ISO"
          parsed_hash[:type_with_stage] = "R"
          parsed_hash.delete(:iso_r_prefix)
        end

        # For NSB-prefixed identifiers (FprISO, WD/ISO), set stage
        if parsed_hash[:nsb_stage]
          nsb_stage = parsed_hash.delete(:nsb_stage)
          # Map NSB stage to typed stage
          case nsb_stage
          when "Fpr"
            parsed_hash[:type_with_stage] = "PRF"
          when "WD"
            parsed_hash[:type_with_stage] = "WD"
          end
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
          copublisher_strings = parsed_hash[:copublishers].map do |cp|
            cp[:copublisher]
          end
          parsed_hash[:publisher] = {
            publisher: parsed_hash[:publisher],
            copublisher: copublisher_strings,
          }
        end

        assign_attributes(identifier, parsed_hash)

        # If typed_stage, stage, or type are still nil after building,
        # set them to the default International Standard values
        if identifier.typed_stage.nil?
          default_typed_stage = Pubid::Iso.locate_stage("")
          identifier.typed_stage = default_typed_stage
          identifier.stage = default_typed_stage.to_stage
          identifier.type = default_typed_stage.to_type
        end

        identifier
      end

      def handle_key(identifier, key, value)
        if key == :joint_identifier
          identifier.additional_identifiers ||= []
          identifier.additional_identifiers << value
          true
        else
          false
        end
      end

      # ISO normalizes em/en dashes, slashes, and spaces to hyphens so that
      # "4037/1979", "4037-1979", and "ISO/IEC DIR 1 IEC" all split cleanly.
      def normalize_number_with_part(value)
        value.to_s
             .tr("#{Parser::DASH_CHARS.join}/", "-")
             .gsub(" ", "-")
      end

      # LEGACY: "ISO 4037-1979" used a hyphen where the modern form is
      # "ISO 4037:1979". When the part looks like a 4-digit year in a
      # plausible range, treat it as a date instead of a part number.
      def extract_legacy_year(number, part, code_class)
        return nil unless part&.match?(/^\d{4}$/)

        year_value = part.to_i
        return nil unless year_value.between?(1900, 2099)

        {
          number: code_class.new(value: number),
          date: ::Pubid::Components::Date.new(year: part),
        }
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
            Pubid::Iso::Components::Publisher.new(
              publisher: value[:publisher],
              copublisher: value[:copublisher],
            )
          else
            # Default copublisher to [] (not nil) so a bare-string publisher
            # (e.g. a TC document, which skips the copublisher merge) matches
            # the [] convention used by copublisher-merged parses and by
            # Identifier.create. Otherwise equality fails on [] vs nil.
            Pubid::Iso::Components::Publisher.new(publisher: value, 
                                                  copublisher: [])
          end

        when :copublishers
          # Copublishers already merged into publisher
          # Create array of Publisher objects for identifier.copublishers attribute
          if value.nil? || value.empty?
            nil
          else
            value.map do |copublisher|
              Pubid::Iso::Components::Publisher.new(publisher: copublisher[:copublisher])
            end
          end

        when :year
          # For TC documents, parser returns :year but identifier uses :date
          # Return as date for assignment
          { date: Pubid::Components::Date.new(year: value.to_s) }

        when :number_with_part
          # "1234" (no part)
          # or "1234-1" ('1' is part)
          # or "1234-1-2" ('1' is part, '2' is subpart)
          # or "29110-5-1-1" ('5' is part, '1-1' is subpart)
          # or "105/F" ('F' is part)
          # or "5843/6" ('6' is part)
          # LEGACY: "4037-1979" (number-year, year should become date)
          parse_number_with_part(value, code_class: Pubid::Iso::Components::Code)

        when :directives_type
          # nothing to do here, just return nil
          nil

        when :type_with_stage
          # "WD"
          # "PAS"
          # "CD TR"
          original_value = value.to_s # Store the original parsed value
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
          Pubid::Components::Iteration.new(number: value.to_s)

        when :date
          parse_date(value)

        when :edition
          # value can be "Ed.2", "Ed 2", "ED1", "Edition 13", or just "Ed"
          original_text = value.to_s
          # Extract just the digit(s) for the number field
          number_string = original_text.match(/\d+/)&.to_s
          number_code = number_string ? Pubid::Iso::Components::Code.new(value: number_string) : nil
          Pubid::Components::Edition.new(number: number_code,
                                         original_text: original_text)

        when :languages
          parse_languages(value)

        when :all_parts
          # Set all_parts boolean attribute directly on identifier
          true

        # ISO 4214:2022 | IDF/RM 254:2022
        when :joint_identifier
          case value[:publisher]
          when "IDF"
            Pubid::Idf.build_from_parse(value)
          end

        when :subgroup
          # Handle JTC 1 subgroup in directives (ISO/IEC JTC 1 DIR)
          # Store as a component for potential use in rendering
          Pubid::Iso::Components::Code.new(value: value.to_s)

        when :supplements
          # Handle bundled supplements (+ operator)
          # Each supplement is a hash that needs to be built
          value.map { |supplement_hash| build(supplement_hash[:supplement]) }

        when :base_document
          # For bundled identifiers, build the base document
          build(value)

        # TC Document attributes
        when :tc_type, :sc_type, :wg_type
          # TC, SC, WG types are code components
          Pubid::Iso::Components::Code.new(value: value.to_s)

        when :tc_number, :sc_number, :wg_number
          # TC, SC, WG numbers are code components
          Pubid::Iso::Components::Code.new(value: value.to_s)

        when :year
          # For TC documents with year, convert to Date
          Pubid::Components::Date.new(year: value.to_s)

        when :number
          # For TC documents, number is the document number (N number)
          # For regular identifiers, this is handled in :number_with_part
          if value.is_a?(Parslet::Slice) || value.is_a?(String) ||
              value.is_a?(Integer)
            Pubid::Iso::Components::Code.new(value: value.to_s)
          else
            value
          end

        when :stage
          # Raw stage code from URN parser (e.g., "10.00", "50.00")
          # Convert to type_with_stage format for builder
          # Look up the typed stage from stage code
          typed_stage = Pubid::Iso.locate_stage_by_stage_code(value.to_s)
          if typed_stage
            typed_stage.abbr.is_a?(Array) ? typed_stage.abbr.first : typed_stage.abbr
          else
            # Fallback: return the raw stage code (shouldn't happen with valid data)
            value.to_s
          end

        else
          raise ArgumentError, "Unknown parameter type: #{type}"
        end
      end
    end
  end
end
