# frozen_string_literal: true

require_relative "components/code"

module PubidNew
  module Oiml
    class Builder
      # Type to identifier class mapping (MECE)
      TYPE_CLASS_MAP = {
        "B" => "BasicPublication",
        "D" => "Document",
        "E" => "ExpertReport",
        "G" => "Guide",
        "R" => "Recommendation",
        "S" => "SeminarReport",
        "V" => "Vocabulary"
      }.freeze

      def build(parsed_hash)
        # Check for short amendment format (has amd_marker)
        if parsed_hash[:amd_marker]
          return build_short_amendment(parsed_hash)
        end

        # Check for supplements first (have base_identifier)
        if parsed_hash[:base_identifier]
          return build_supplement(parsed_hash)
        end

        # Build base document
        build_base_document(parsed_hash)
      end

      private

      def build_short_amendment(parsed_hash)
        # Build base identifier from the code and type
        base_hash = {
          publisher: parsed_hash[:publisher],
          type: parsed_hash[:type]
        }

        # Copy number/part/subpart from base_code
        if parsed_hash[:base_code]
          base_hash[:number] = parsed_hash[:base_code][:number]
          base_hash[:part] = parsed_hash[:base_code][:part] if parsed_hash[:base_code][:part]
          base_hash[:subpart] = parsed_hash[:base_code][:subpart] if parsed_hash[:base_code][:subpart]
        end

        # Build the base document
        base_identifier = build_base_document(base_hash)

        # Create amendment
        amendment = Identifiers::Amendment.new
        amendment.base_identifier = base_identifier

        # Extract year from edition_format if present, otherwise from year directly
        year_value = if parsed_hash[:edition_format].is_a?(Hash)
          parsed_hash[:edition_format][:year]
        else
          parsed_hash[:year]
        end

        amendment.year = year_value.to_s if year_value
        amendment.language = extract_language(parsed_hash[:language]) if parsed_hash[:language]

        # Track if amendment itself was parsed with Edition format
        if parsed_hash[:edition_format]
          amendment.parsed_format = "long"
        end

        amendment
      end

      def build_supplement(parsed_hash)
        # Determine supplement type
        supplement_class = if parsed_hash[:annex_letter] || parsed_hash[:annex_marker]
          Identifiers::Annex
        else
          Identifiers::Amendment
        end

        supplement = supplement_class.new

        # Recursively parse base identifier
        if parsed_hash[:base_identifier]
          supplement.base_identifier = build(parsed_hash[:base_identifier])
        end

        # Extract year from edition_format if present, otherwise from year directly
        year_value = if parsed_hash[:edition_format].is_a?(Hash)
          parsed_hash[:edition_format][:year]
        else
          parsed_hash[:year]
        end

        # Set supplement-specific attributes
        supplement.year = year_value.to_s if year_value
        supplement.language = extract_language(parsed_hash[:language]) if parsed_hash[:language]
        supplement.letter = parsed_hash[:annex_letter].to_s if parsed_hash[:annex_letter]

        # Track if supplement itself was parsed with Edition format
        if parsed_hash[:edition_format]
          supplement.parsed_format = "long"
        end

        supplement
      end

      def build_base_document(parsed_hash)
        # Determine identifier class from type
        type = parsed_hash[:type].to_s
        class_name = TYPE_CLASS_MAP[type] || "Recommendation"  # Default to R
        identifier_class = Identifiers.const_get(class_name)

        identifier = identifier_class.new

        # Handle code (number-part-subpart) specially
        if parsed_hash[:number] || parsed_hash[:part] || parsed_hash[:subpart]
          code_attrs = {}
          code_attrs[:number] = parsed_hash[:number].to_s if parsed_hash[:number]
          code_attrs[:part] = parsed_hash[:part].to_s if parsed_hash[:part]
          code_attrs[:subpart] = parsed_hash[:subpart].to_s if parsed_hash[:subpart]
          identifier.code = Components::Code.new(**code_attrs)
        end

        # Handle other attributes
        identifier.publisher = parsed_hash[:publisher].to_s if parsed_hash[:publisher]

        # Handle edition attribute
        identifier.edition = parsed_hash[:edition].to_s if parsed_hash[:edition]

        # Handle year -> date conversion
        # Year could be in edition_format hash or directly
        year_value = nil
        if parsed_hash[:edition_format].is_a?(Hash)
          year_value = parsed_hash[:edition_format][:year]
          # Also extract edition if present
          identifier.edition = parsed_hash[:edition_format][:edition].to_s if parsed_hash[:edition_format][:edition]
        elsif parsed_hash[:year]
          year_value = parsed_hash[:year]
        end

        if year_value
          identifier.date = PubidNew::Components::Date.new(year: year_value.to_s)
        end

        # Determine parsed format for round-trip fidelity
        # If edition_format was captured, it means "Edition" text was present
        if parsed_hash[:edition_format]
          identifier.parsed_format = "long"
        elsif parsed_hash[:space_before_lang]
          identifier.parsed_format = "short_with_space"
        else
          identifier.parsed_format = "short"
        end

        # Handle stage attributes
        identifier.stage = parsed_hash[:stage].to_s if parsed_hash[:stage]
        identifier.iteration = parsed_hash[:iteration].to_s if parsed_hash[:iteration]

        # Handle language
        identifier.language = extract_language(parsed_hash[:language]) if parsed_hash[:language]

        identifier
      end

      def extract_language(lang_data)
        # Handle both direct string and nested hash from parser
        case lang_data
        when Hash
          lang_data[:language].to_s
        else
          lang_data.to_s
        end
      end
    end
  end
end