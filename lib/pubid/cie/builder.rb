# frozen_string_literal: true

module Pubid
  module Cie
    # Builder transforms parsed data into CIE identifier objects
    # Single Responsibility: Object construction from parse tree
    class Builder
      def initialize
        # Builder doesn't need scheme for CIE (simpler than ISO/IEC)
      end

      # Build identifier from parsed hash
      def build(parsed_hash, original_string: nil)
        # Determine identifier class based on parsed content
        identifier_class = determine_class(parsed_hash)

        # Supplement / Corrigendum wrap a nested base_identifier.
        if identifier_class == Cie::Identifiers::Corrigendum
          return build_corrigendum(parsed_hash)
        end
        if identifier_class == Cie::Identifiers::Supplement
          return build_supplement(parsed_hash)
        end

        # Extract attributes with style detection
        attributes = extract_attributes(parsed_hash)

        # For Bundle identifier, store original string
        if parsed_hash[:bundle_items] && original_string
          attributes[:identifiers_string] = original_string
        end

        # Construct identifier
        identifier_class.new(**attributes)
      end

      private

      # Supplement: nest the base Standard (the stage/year/language belong to
      # the base), keep only the -SPN number/part on the wrapper.
      def build_supplement(parsed_hash)
        a = extract_attributes(parsed_hash)
        base = Cie::Identifiers::Standard.new(
          number: a[:base_number],
          stage: a[:stage],
          s_prefix: a.fetch(:s_prefix, false),
          language: a[:language],
          year: a[:year],
          style: "current", # supplements always use the colon style
        )
        Cie::Identifiers::Supplement.new(
          base_identifier: base,
          supplement_number: a[:supplement_number],
          supplement_part: a[:supplement_part],
        )
      end

      # Corrigendum: nest the base (a Standard, or a Supplement when the base
      # itself carries -SPN), keep only the /CorN number/year on the wrapper.
      def build_corrigendum(parsed_hash)
        a = extract_attributes(parsed_hash)
        base_std = Cie::Identifiers::Standard.new(
          number: a[:base_number],
          year: a[:base_year],
          style: "current",
        )
        base = if a[:base_supplement]
                 Cie::Identifiers::Supplement.new(
                   base_identifier: base_std,
                   supplement_number: a[:base_supplement],
                   supplement_part: a[:base_supplement_part],
                 )
               else
                 base_std
               end
        Cie::Identifiers::Corrigendum.new(
          base_identifier: base,
          cor_number: a[:cor_number],
          cor_year: a[:cor_year],
        )
      end

      # Determine which identifier class to use
      def determine_class(parsed_hash)
        # Tutorial Bundle (special text format)
        if parsed_hash[:bundle_number] && !parsed_hash[:first_number]
          return Cie::Identifiers::TutorialBundle
        end

        # Bundle (comma-separated)
        if parsed_hash[:bundle_items]
          return Cie::Identifiers::Bundle
        end

        # Corrigendum (/CorN)
        if parsed_hash[:cor_number]
          return Cie::Identifiers::Corrigendum
        end

        # Supplement (-SPN)
        if parsed_hash[:supplement_number] && !parsed_hash[:cor_number]
          return Cie::Identifiers::Supplement
        end

        # Proceedings paper (x-prefixed or standalone)
        if parsed_hash[:paper_code]
          return Cie::Identifiers::Proceedings
        end

        # Conference (x-prefix)
        if parsed_hash[:conference]
          return Cie::Identifiers::Conference
        end

        # Dual published with IEC
        if parsed_hash[:iec_identifier]
          return Cie::Identifiers::DualPublished
        end

        # Identical with ISO
        if parsed_hash[:iso_reference]
          return Cie::Identifiers::Identical
        end

        # Joint with copublisher (ISO, IEC, or ISO/CIE)
        if parsed_hash[:copublisher]
          return Cie::Identifiers::JointPublished
        end

        # Standard (default)
        Cie::Identifiers::Standard
      end

      # Extract attributes from parsed hash
      def extract_attributes(parsed_hash)
        attributes = {}

        # Extract year and date separator from wrapped date format
        year_value = nil
        date_sep = nil

        # Handle the new wrapped formats from parser
        if parsed_hash[:date_then_lang]
          # date_then_lang: { current_date: { year: ... } } or { legacy_date: { year: ... } }, language: ...
          date_data = parsed_hash[:date_then_lang]
          if date_data[:current_date]
            year_value = extract_value(date_data[:current_date][:year])
            date_sep = "colon"
          elsif date_data[:legacy_date]
            year_value = extract_value(date_data[:legacy_date][:year])
            date_sep = "dash"
          end
          # Extract language from date_then_lang if present
          if date_data[:language_paren_year]
            lang_data = date_data[:language_paren_year]
            lang_code = extract_value(lang_data[:lang_code])
            trans_year = extract_value(lang_data[:trans_year])
            lang_format = "paren_year"
            if lang_code
              lang_attrs = { code: lang_code, format: lang_format }
              lang_attrs[:translation_year] = trans_year if trans_year
              attributes[:language] = Components::Language.new(**lang_attrs)
            end
          elsif date_data[:language_paren]
            lang_data = date_data[:language_paren]
            lang_code = extract_value(lang_data[:lang_code])
            lang_format = "paren"
            if lang_code
              lang_attrs = { code: lang_code, format: lang_format }
              attributes[:language] = Components::Language.new(**lang_attrs)
            end
          elsif date_data[:language_slash]
            lang_data = date_data[:language_slash]
            lang_code = extract_value(lang_data[:lang_code])
            lang_format = "slash"
            if lang_code
              lang_attrs = { code: lang_code, format: lang_format }
              attributes[:language] = Components::Language.new(**lang_attrs)
            end
          end
        elsif parsed_hash[:lang_before]
          # lang_before: { language: ..., current_date/legacy_date: ... }
          lang_data = parsed_hash[:lang_before]
          if lang_data[:language_paren]
            lang_info = lang_data[:language_paren]
            lang_code = extract_value(lang_info[:lang_code])
            lang_format = "paren"
            if lang_code
              lang_attrs = { code: lang_code, format: lang_format }
              attributes[:language] = Components::Language.new(**lang_attrs)
            end
          elsif lang_data[:language_slash]
            lang_info = lang_data[:language_slash]
            lang_code = extract_value(lang_info[:lang_code])
            lang_format = "slash"
            if lang_code
              lang_attrs = { code: lang_code, format: lang_format }
              attributes[:language] = Components::Language.new(**lang_attrs)
            end
          end
          # Extract date from lang_before
          if lang_data[:current_date]
            year_value = extract_value(lang_data[:current_date][:year])
            date_sep = "colon"
          elsif lang_data[:legacy_date]
            year_value = extract_value(lang_data[:legacy_date][:year])
            date_sep = "dash"
          end
        elsif parsed_hash[:current_date]
          year_value = extract_value(parsed_hash[:current_date][:year])
          date_sep = "colon"
        elsif parsed_hash[:legacy_date]
          year_value = extract_value(parsed_hash[:legacy_date][:year])
          date_sep = "dash"
        elsif parsed_hash[:year]
          # Direct year (for joint patterns or legacy_code_with_year)
          year_value = extract_value(parsed_hash[:year])

          # For joint patterns, infer separator based on copublisher
          if parsed_hash[:copublisher]
            copub = extract_value(parsed_hash[:copublisher])
            # IEC uses dash, ISO uses colon (by convention for modern docs)
            date_sep = copub == "IEC" ? "dash" : "colon"
          elsif parsed_hash[:trailing_lang]
            # If trailing_lang exists, this came from legacy_code_with_year
            # which uses dash as the year separator (parsed as NUMBER-YEAR)
            date_sep = "dash"
          else
            # Default: infer from year value (pre-2001 = dash, post-2001 = colon)
            year_int = year_value.to_i
            date_sep = year_int <= 2001 ? "dash" : "colon"
          end
        elsif parsed_hash[:slash_year]
          # Slash-year format (legacy): /1998
          year_value = extract_value(parsed_hash[:slash_year])
          date_sep = "slash" # Special format for identical identifiers
        end

        # Style is the sole separator field (no date_separator):
        #   colon -> current (":")   dash -> legacy ("-")   slash -> slash ("/")
        style = case date_sep
                when "colon" then "current"
                when "dash" then "legacy"
                when "slash" then "slash"
                else detect_style_fallback(parsed_hash)
                end
        attributes[:style] = style

        # Set year if present
        attributes[:year] = year_value if year_value

        # Extract code (flat number/part/iteration/part_separator on the
        # identifier; the code's style is the identifier's own `style`).
        if parsed_hash[:number]
          attributes[:number] = extract_value(parsed_hash[:number])
          if parsed_hash[:part]
            attributes[:part] = extract_value(parsed_hash[:part])
          end
          if parsed_hash[:iteration]
            attributes[:iteration] = extract_value(parsed_hash[:iteration])
          end

          # Detect part separator from parser markers
          if parsed_hash[:slash_sep]
            attributes[:part_separator] = "slash"
          elsif parsed_hash[:dash_sep]
            attributes[:part_separator] = "dash"
          end
        end

        # Conference number (separate from regular code)
        if parsed_hash[:conf_number]
          attributes[:number] =
            extract_value(parsed_hash[:conf_number])
        end

        # Proceedings paper identity (code + number) as a Components::Paper
        if parsed_hash[:paper_code]
          attributes[:paper] = Components::Paper.new(
            code: extract_value(parsed_hash[:paper_code]),
            number: extract_value(parsed_hash[:paper_number]),
          )
        end
        if parsed_hash[:page_range]
          attributes[:page_range] = extract_value(parsed_hash[:page_range])
        end

        # Conference /slug variant (opaque, verbatim)
        if parsed_hash[:variant]
          attributes[:variant] = extract_value(parsed_hash[:variant])
        end

        # D-series marker
        attributes[:d_prefix] = true if parsed_hash[:d_prefix]

        # Extract language (direct lang_code for slash_colon format)
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
          # Direct lang_code from identical_with_iso or standard_with_language_year patterns
          # Format: /E:2001 (with colon)
          lang_code = extract_value(parsed_hash[:lang_code])
          # Check if colon was present in the pattern
          if parsed_hash[:lang_colon]
            lang_format = "slash_colon" # /E:YYYY format
          else
            # This shouldn't happen with preprocessing, but default to slash
            lang_format = "slash"
          end
        end

        if lang_code
          lang_attrs = { code: lang_code, format: lang_format }
          lang_attrs[:translation_year] = trans_year if trans_year
          attributes[:language] = Components::Language.new(**lang_attrs)
        end

        # Extract S prefix flag
        attributes[:s_prefix] = parsed_hash[:s_prefix] ? true : false

        # Extract stage
        if parsed_hash[:stage]
          attributes[:stage] =
            extract_value(parsed_hash[:stage])
        end

        # Extract doc type
        if parsed_hash[:doc_type]
          attributes[:doc_type] =
            extract_value(parsed_hash[:doc_type])
        end

        # Extract copublisher info
        if parsed_hash[:copublisher]
          attributes[:copublisher] = extract_value(parsed_hash[:copublisher])
        end

        # Extract ISO reference (for identical identifiers)
        if parsed_hash[:iso_reference]
          attributes[:iso_reference] =
            extract_value(parsed_hash[:iso_reference])
        end

        # Extract IEC identifier (for dual published)
        if parsed_hash[:iec_identifier]
          attributes[:iec_identifier] =
            extract_value(parsed_hash[:iec_identifier])
        end

        # Extract supplement data
        if parsed_hash[:supplement_number]
          attributes[:supplement_number] =
            extract_value(parsed_hash[:supplement_number])
          if parsed_hash[:supplement_part]
            attributes[:supplement_part] =
              extract_value(parsed_hash[:supplement_part])
          end
          if parsed_hash[:base_number]
            attributes[:base_number] =
              extract_value(parsed_hash[:base_number])
          end
        end

        # Extract corrigendum data
        if parsed_hash[:cor_number]
          attributes[:cor_number] = extract_value(parsed_hash[:cor_number])
          attributes[:cor_year] = extract_value(parsed_hash[:cor_year])
          attributes[:base_number] = extract_value(parsed_hash[:base_number])
          attributes[:base_year] = extract_value(parsed_hash[:base_year])
          if parsed_hash[:base_supplement]
            attributes[:base_supplement] =
              extract_value(parsed_hash[:base_supplement])
          end
          if parsed_hash[:base_supplement_part]
            attributes[:base_supplement_part] =
              extract_value(parsed_hash[:base_supplement_part])
          end
        end

        # Extract amendment (on conference)
        if parsed_hash[:amd_number]
          attributes[:amendment_number] =
            extract_value(parsed_hash[:amd_number])
        end

        # Extract bundle data
        if parsed_hash[:bundle_number]
          attributes[:bundle_number] =
            extract_value(parsed_hash[:bundle_number])
        end

        # Extract trailing language from legacy_code_with_year
        if parsed_hash[:trailing_lang].is_a?(Hash)
          lang_data = parsed_hash[:trailing_lang]
          # trailing_lang contains language_paren_year hash
          if lang_data[:language_paren_year]
            lang_info = lang_data[:language_paren_year]
            lang_code = extract_value(lang_info[:lang_code])
            trans_year = extract_value(lang_info[:trans_year])
            if lang_code
              lang_attrs = { code: lang_code, format: "paren_year" }
              lang_attrs[:translation_year] = trans_year if trans_year
              attributes[:language] = Components::Language.new(**lang_attrs)
            end
          end
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
          joined = value.join
          return joined.length.positive? ? joined : nil
        end

        str_value = value.to_s.strip
        str_value.length.positive? ? str_value : nil
      end
    end
  end
end
