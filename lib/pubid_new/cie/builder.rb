# frozen_string_literal: true

require_relative "components/code"
require_relative "components/language"

module PubidNew
  module Cie
    # Builder transforms parsed data into CIE identifier objects
    # Single Responsibility: Object construction from parse tree
    class Builder
      def initialize
        # Builder doesn't need scheme for CIE (simpler than ISO/IEC)
      end

      # Build identifier from parsed hash
      def build(parsed_hash)
        # Determine identifier class based on parsed content
        identifier_class = determine_class(parsed_hash)

        # Extract attributes with style detection
        attributes = extract_attributes(parsed_hash)

        # Construct identifier
        identifier_class.new(**attributes)
      end

      private

      # Determine which identifier class to use
      def determine_class(parsed_hash)
        # Tutorial Bundle (special text format)
        if parsed_hash[:bundle_number] && !parsed_hash[:first_number]
          require_relative "identifiers/tutorial_bundle"
          return Identifiers::TutorialBundle
        end

        # Bundle (comma-separated)
        if parsed_hash[:bundle_items]
          require_relative "identifiers/bundle"
          return Identifiers::Bundle
        end

        # Corrigendum (/CorN)
        if parsed_hash[:cor_number]
          require_relative "identifiers/corrigendum"
          return Identifiers::Corrigendum
        end

        # Supplement (-SPN)
        if parsed_hash[:supplement_number] && !parsed_hash[:cor_number]
          require_relative "identifiers/supplement"
          return Identifiers::Supplement
        end

        # Conference (x-prefix)
        if parsed_hash[:conference]
          require_relative "identifiers/conference"
          return Identifiers::Conference
        end

        # Dual published with IEC
        if parsed_hash[:iec_identifier]
          require_relative "identifiers/dual_published"
          return Identifiers::DualPublished
        end

        # Identical with ISO
        if parsed_hash[:iso_reference]
          require_relative "identifiers/identical"
          return Identifiers::Identical
        end

        # Joint with copublisher (ISO, IEC, or ISO/CIE)
        if parsed_hash[:copublisher]
          require_relative "identifiers/joint_published"
          return Identifiers::JointPublished
        end

        # Standard (default)
        require_relative "identifiers/standard"
        Identifiers::Standard
      end

      # Extract attributes from parsed hash
      def extract_attributes(parsed_hash)
        attributes = {}

        # Extract year and date separator from wrapped date format
        year_value = nil
        date_sep = nil

        if parsed_hash[:current_date]
          year_value = extract_value(parsed_hash[:current_date][:year])
          date_sep = "colon"
        elsif parsed_hash[:legacy_date]
          year_value = extract_value(parsed_hash[:legacy_date][:year])
          date_sep = "dash"
        elsif parsed_hash[:year]
          # Direct year (for joint patterns - infer separator)
          year_value = extract_value(parsed_hash[:year])
          # For joint patterns, infer separator based on copublisher
          if parsed_hash[:copublisher]
            copub = extract_value(parsed_hash[:copublisher])
            # IEC uses dash, ISO uses colon (by convention for modern docs)
            date_sep = copub == "IEC" ? "dash" : "colon"
          else
            # Default to colon for current style
            date_sep = "colon"
          end
        elsif parsed_hash[:slash_year]
          # Slash-year format (legacy): /1998
          year_value = extract_value(parsed_hash[:slash_year])
          date_sep = "slash"  # Special format for identical identifiers
        end

        # Detect style from date separator
        style = date_sep == "colon" ? "current" : (date_sep == "dash" ? "legacy" : detect_style_fallback(parsed_hash))
        attributes[:style] = style

        # Set year and separator if present
        attributes[:year] = year_value if year_value
        attributes[:date_separator] = date_sep if date_sep

        # Extract code
        if parsed_hash[:number]
          code_attrs = { number: extract_value(parsed_hash[:number]), style: style }
          code_attrs[:part] = extract_value(parsed_hash[:part]) if parsed_hash[:part]
          code_attrs[:iteration] = extract_value(parsed_hash[:iteration]) if parsed_hash[:iteration]

          attributes[:code] = Components::Code.new(**code_attrs)
        end

        # Conference number (separate from regular code)
        if parsed_hash[:conf_number]
          attributes[:conference_number] = extract_value(parsed_hash[:conf_number])
        end

        # Extract language
        lang_code = nil
        lang_format = nil
        trans_year = nil
        if parsed_hash[:language_paren_year]
          lang_data = parsed_hash[:language_paren_year]
          lang_code = extract_value(lang_data[:lang_code])
          trans_year = extract_value(lang_data[:trans_year])
          lang_format = "paren_year"
        elsif parsed_hash[:language_paren]
          lang_data = parsed_hash[:language_paren]
          lang_code = extract_value(lang_data[:lang_code])
          lang_format = "paren"
        elsif parsed_hash[:language_slash]
          lang_data = parsed_hash[:language_slash]
          lang_code = extract_value(lang_data[:lang_code])
          lang_format = "slash"
        elsif parsed_hash[:lang_code]
          # Direct lang_code from identical_with_iso pattern (/E:2001)
          lang_code = extract_value(parsed_hash[:lang_code])
          lang_format = "slash"  # Came from slash pattern
        end

        if lang_code
          lang_attrs = { code: lang_code, format: lang_format }
          lang_attrs[:translation_year] = trans_year if trans_year
          attributes[:language] = Components::Language.new(**lang_attrs)
        end

        # Extract S prefix flag
        attributes[:s_prefix] = parsed_hash[:s_prefix] ? true : false

        # Extract stage
        attributes[:stage] = extract_value(parsed_hash[:stage]) if parsed_hash[:stage]

        # Extract doc type
        attributes[:doc_type] = extract_value(parsed_hash[:doc_type]) if parsed_hash[:doc_type]

        # Extract copublisher info
        if parsed_hash[:copublisher]
          attributes[:copublisher] = extract_value(parsed_hash[:copublisher])
        end

        # Extract ISO reference (for identical identifiers)
        if parsed_hash[:iso_reference]
          attributes[:iso_reference] = extract_value(parsed_hash[:iso_reference])
        end

        # Extract IEC identifier (for dual published)
        if parsed_hash[:iec_identifier]
          attributes[:iec_identifier] = extract_value(parsed_hash[:iec_identifier])
        end

        # Extract supplement data
        if parsed_hash[:supplement_number]
          attributes[:supplement_number] = extract_value(parsed_hash[:supplement_number])
          attributes[:supplement_part] = extract_value(parsed_hash[:supplement_part]) if parsed_hash[:supplement_part]
          attributes[:base_number] = extract_value(parsed_hash[:base_number]) if parsed_hash[:base_number]
        end

        # Extract corrigendum data
        if parsed_hash[:cor_number]
          attributes[:cor_number] = extract_value(parsed_hash[:cor_number])
          attributes[:cor_year] = extract_value(parsed_hash[:cor_year])
          attributes[:base_number] = extract_value(parsed_hash[:base_number])
          attributes[:base_year] = extract_value(parsed_hash[:base_year])
          attributes[:base_supplement] = extract_value(parsed_hash[:base_supplement]) if parsed_hash[:base_supplement]
          attributes[:base_supplement_part] = extract_value(parsed_hash[:base_supplement_part]) if parsed_hash[:base_supplement_part]
        end

        # Extract amendment (on conference)
        if parsed_hash[:amd_number]
          attributes[:amendment_number] = extract_value(parsed_hash[:amd_number])
        end

        # Extract bundle data
        if parsed_hash[:bundle_number]
          attributes[:bundle_number] = extract_value(parsed_hash[:bundle_number])
        end

        attributes
      end

      # Detect style from date separator
      def detect_style(parsed_hash)
        # Check for current_date or legacy_date wrapper
        if parsed_hash[:current_date]
          return "current"
        elsif parsed_hash[:legacy_date]
          return "legacy"
        end

        # Fallback
        detect_style_fallback(parsed_hash)
      end

      # Fallback style detection based on year
      def detect_style_fallback(parsed_hash)
        # Fallback: year-based heuristic
        if parsed_hash[:year]
          year = extract_value(parsed_hash[:year]).to_i
          return year <= 2001 ? "legacy" : "current"
        elsif parsed_hash[:current_date] && parsed_hash[:current_date][:year]
          year = extract_value(parsed_hash[:current_date][:year]).to_i
          return year <= 2001 ? "legacy" : "current"
        elsif parsed_hash[:legacy_date] && parsed_hash[:legacy_date][:year]
          year = extract_value(parsed_hash[:legacy_date][:year]).to_i
          return year <= 2001 ? "legacy" : "current"
        end

        # Default to current
        "current"
      end

      # Extract value from parsed element
      def extract_value(value)
        return nil if value.nil?
        return nil if value.is_a?(Array) && value.empty?

        if value.is_a?(Array)
          joined = value.map(&:to_s).join
          return joined.length > 0 ? joined : nil
        end

        str_value = value.to_s.strip
        str_value.length > 0 ? str_value : nil
      end
    end
  end
end
