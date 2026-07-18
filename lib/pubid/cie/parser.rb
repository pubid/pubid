# frozen_string_literal: true

require "parslet"

module Pubid
  module Cie
    # Parser for CIE identifiers
    # Handles dual-style system (legacy vs current)
    class Parser < Parslet::Parser
      # Basic building blocks
      rule(:space) { str(" ") }
      rule(:space?) { space.maybe }
      rule(:dash) { str("-") }
      rule(:colon) { str(":") }
      rule(:dot) { str(".") }
      rule(:slash) { str("/") }
      rule(:comma) { str(",") }
      rule(:digit) { match("[0-9]") }
      rule(:digits) { digit.repeat(1) }
      rule(:upper) { match("[A-Z]") }
      rule(:lower) { match("[a-z]") }

      # Year (4 digits: 1900-2099)
      rule(:year_digits) do
        (str("19") | str("20")) >> digit.repeat(2, 2)
      end

      # Date with separator detection (CRITICAL for style)
      # Legacy: dash "-" (pre-2001)
      # Current: colon ":" (2001+)
      rule(:legacy_date) do
        (dash >> year_digits.as(:year)).as(:legacy_date)
      end

      rule(:current_date) do
        (colon >> year_digits.as(:year)).as(:current_date)
      end

      rule(:date) do
        current_date | legacy_date
      end

      # Legacy format: NUMBER-YEAR (e.g., 001-1980)
      # This is BEFORE 2001, using dash as year separator (NOT part)
      # Can optionally have trailing language like "(RU-2020)"
      rule(:legacy_code_with_year) do
        str("CIE") >> space >> digits.as(:number) >> dash >> year_digits.as(:year) >>
          (language_paren_year | str("")).as(:trailing_lang)
      end

      # Code patterns
      # Pattern 1: "006.1" - iteration (leading zero + dot)
      rule(:code_with_iteration) do
        digits.as(:number) >> dot >> digits.as(:iteration)
      end

      # Pattern 1b: "19/2.1" - part with slash THEN iteration with dot (complex)
      rule(:code_with_part_and_iteration_slash) do
        digits.as(:number) >> slash >> digits.as(:part) >> dot >> digits.as(:iteration)
      end

      # Pattern 1c: "19-2.1" - part with dash THEN iteration with dot (complex)
      rule(:code_with_part_and_iteration_dash) do
        digits.as(:number) >> dash >> digits.as(:part) >> dot >> digits.as(:iteration) >>
          dash.absent? # Don't consume date dash
      end

      # Pattern 2: "170-1" - part with dash (current style)
      # NOTE: Part must be 1-3 digits, and NOT followed by a 4-digit year
      rule(:code_with_part_dash) do
        digits.as(:number) >> dash >> match("[0-9]").repeat(1, 3).as(:part) >>
          str("").as(:dash_sep) >> # Marker for dash separator
          # Negative lookahead: don't consume if followed by 4-digit year
          (str("19") | str("20")).absent? >>
          (dot | dash).absent? # Don't consume dot or date dash
      end

      # Pattern 3: "170/1" - part with slash (legacy style)
      rule(:code_with_part_slash) do
        digits.as(:number) >> slash >> digits.as(:part) >>
          str("").as(:slash_sep) >> # Marker for slash separator
          dot.absent? # Don't consume iteration dot
      end

      # Pattern 4: Simple number
      rule(:code_simple) do
        digits.as(:number)
      end

      # Code rule (longest match first - complex patterns before simple)
      rule(:code) do
        code_with_part_and_iteration_slash |
          code_with_part_and_iteration_dash |
          code_with_iteration |
          code_with_part_slash |
          code_with_part_dash |
          code_simple
      end

      # Language patterns
      # Format 1: /E, /F, /G (slash-prefix, legacy)
      rule(:language_slash) do
        (slash >> upper.as(:lang_code)).as(:language_slash)
      end

      # Format 2: (DE), (ES), (CN), (en), (E), (F), (G)
      rule(:language_paren) do
        (str("(") >> match("[A-Za-z]").repeat(1,
                                              3).as(:lang_code) >> str(")")).as(:language_paren)
      end

      # Format 3: (RU-2021) - with translation year
      # NOTE: The space before parenthesis is OPTIONAL (e.g., "2003 (RU-2021)" or "2003(RU-2021)")
      rule(:language_paren_year) do
        (space.maybe >> str("(") >> upper.repeat(2).as(:lang_code) >>
        dash >> year_digits.as(:trans_year) >> str(")")).as(:language_paren_year)
      end

      rule(:language) do
        language_paren_year | language_paren | language_slash
      end

      # S prefix (optional "Standard" marker)
      rule(:s_prefix) do
        str("S") >> space
      end

      # Conference x-prefix
      rule(:x_prefix) do
        str("x")
      end

      # Stage codes (DIS, DS, FDIS, etc.)
      rule(:stage_code) do
        (str("FDIS") | str("DIS") | str("DS")) >> space
      end

      # Document type (TR for Technical Report)
      rule(:doc_type) do
        str("TR") # Don't consume trailing space
      end

      # DIS stage with supplement pattern (e.g., DIS 025-SP1/E:2019)
      rule(:dis_with_supplement) do
        str("CIE") >> space >>
          stage_code.as(:stage) >>
          s_prefix.maybe.as(:s_prefix) >>
          digits.as(:base_number) >>
          dash >> str("SP") >> digits.as(:supplement_number) >>
          (dot >> digits.as(:supplement_part)).maybe >>
          slash >> upper.as(:lang_code) >> colon.as(:lang_colon) >> year_digits.as(:year)
      end

      # Standard identifier (most common) - language can come AFTER date
      rule(:standard_identifier) do
        str("CIE") >> space >>
          stage_code.maybe.as(:stage) >>
          s_prefix.maybe.as(:s_prefix) >>
          code >>
          # Language can come BEFORE date, AFTER date, or both.
          # The whole date group is optional so a bare "CIE 015" (no year)
          # parses with year left nil (partial reference for relaton matching).
          (
            (language >> date).as(:lang_before) |
            (date >> language.maybe).as(:date_then_lang) |
            date
          ).maybe
      end

      # Standard identifier without ISO reference but with language-year (CIE S 014-4/E:2007)
      rule(:standard_with_language_year) do
        str("CIE") >> space >>
          stage_code.maybe.as(:stage) >>
          s_prefix.maybe.as(:s_prefix) >>
          code >>
          slash >> upper.as(:lang_code) >> colon.as(:lang_colon) >> year_digits.as(:year)
      end

      # Conference identifier (x-prefix)
      rule(:conference_identifier) do
        str("CIE") >> space >>
          x_prefix.as(:conference) >>
          digits.as(:conf_number) >>
          date >>
          # Optional amendment
          (space >> str("Amendment") >> space >> digits.as(:amd_number)).maybe
      end

      # Joint published with ISO
      rule(:joint_with_iso) do
        str("CIE") >> space >>
          str("ISO").as(:copublisher) >> # Match and mark once
          (slash >> str("CIE")).absent? >> # Make sure it's not "ISO/CIE"
          space >>
          (doc_type >> space).maybe.as(:doc_type) >> # Consume space here
          stage_code.maybe.as(:stage) >>
          digits.as(:number) >>
          (dash >> digits.as(:part)).maybe >>
          ((colon >> year_digits.as(:year)) | (dash >> year_digits.as(:year))).maybe >>
          language.maybe
      end

      # Joint with ISO/CIE (special case)
      rule(:joint_with_iso_cie) do
        str("CIE") >> space >>
          str("ISO/CIE").as(:copublisher) >> # Match and mark once
          space >>
          (doc_type >> space).maybe.as(:doc_type) >> # Consume space here
          digits.as(:number) >>
          (colon >> year_digits.as(:year)).maybe >>
          language.maybe
      end

      # Joint published with IEC
      rule(:joint_with_iec) do
        str("CIE") >> space >>
          str("IEC").as(:copublisher) >> # Match and mark once
          space >>
          digits.as(:number) >>
          dot >> digits.as(:part) >> # IEC always uses dot
          dash >> year_digits.as(:year)
      end

      # Identical with ISO (parenthetical reference)
      # Patterns:
      # "CIE S 006.1/1998 (ISO 16508:1999)" - iteration with dot
      # "CIE S 014-4/E2007" - part with dash + language without colon (needs colon insertion)
      # "CIE S 008/E:2001 (ISO 8995-1:2002(E))" - language with colon year
      rule(:identical_with_iso) do
        str("CIE") >> space >>
          s_prefix.maybe.as(:s_prefix) >>
          digits.as(:number) >>
          # Can have iteration (.1) OR part (-4)
          (
            (dot >> digits.as(:iteration)) |
            (dash >> digits.as(:part))
          ).maybe >>
          # Slash handling - three mutually exclusive patterns:
          (slash >>
            (
              # /E:2001 - language code WITH colon year
              (upper.as(:lang_code) >> colon.as(:lang_colon) >> year_digits.as(:year)) |
              # /E2007 - language code WITHOUT colon + year (needs colon insertion)
              (upper.as(:lang_code) >> year_digits.as(:year)) |
              # /1998 - just legacy slash-year (no language)
              year_digits.as(:slash_year)
            )
          ).maybe >>
          # ISO reference - handle nested parentheses for language codes
          space >> str("(ISO") >> space >>
          # Match ISO identifier: digits, colons, dashes, slashes, dots
          # Plus optional language code in parentheses like (E), (F)
          (
            match("[0-9A-Z:/.\\-]").repeat(1) >> # Main ISO identifier
            (str("(") >> match("[A-Z]").repeat(1) >> str(")")).maybe # Optional (E), (F), etc.
          ).as(:iso_reference) >>
          str(")")
      end

      # Dual published with IEC (slash separator between full identifiers)
      # Pattern: "CIE S 009:2002/IEC 62471:2006"
      rule(:dual_with_iec) do
        str("CIE") >> space >>
          s_prefix.maybe.as(:s_prefix) >>
          digits.as(:number) >>
          colon >> year_digits.as(:year) >>
          slash >> str("IEC") >> space >>
          match("[^)\\n]").repeat(1).as(:iec_identifier)
      end

      # Supplement identifier (-SPN notation)
      rule(:supplement_identifier) do
        str("CIE") >> space >>
          digits.as(:base_number) >>
          dash >> str("SP") >> digits.as(:supplement_number) >>
          (dot >> digits.as(:supplement_part)).maybe >>
          colon >> year_digits.as(:year)
      end

      # Corrigendum identifier (/CorN notation)
      rule(:corrigendum_identifier) do
        # Parse base identifier first (could be supplement or standard)
        str("CIE") >> space >>
          digits.as(:base_number) >>
          # Could have supplement notation before corrigendum
          (dash >> str("SP") >> digits.as(:base_supplement) >>
           (dot >> digits.as(:base_supplement_part)).maybe).maybe >>
          colon >> year_digits.as(:base_year) >>
          # Corrigendum portion
          slash >> str("Cor") >> digits.as(:cor_number) >>
          colon >> year_digits.as(:cor_year)
      end

      # Bundle identifier (comma-separated list)
      rule(:bundle_identifier) do
        str("CIE") >> space >>
          digits.as(:first_number) >>
          dash >> str("SP") >> digits >> dot >> digits >>
          colon >> year_digits >>
          (comma >> digits.as(:next_number) >>
           dash >> str("SP") >> digits >> dot >> digits >>
           colon >> year_digits).repeat(1).as(:bundle_items)
      end

      # Tutorial Bundle
      rule(:tutorial_bundle) do
        str("CIE Tutorials Bundle") >> space >> digits.as(:bundle_number)
      end

      # Main identifier rule (longest/most specific first)
      root(:identifier)

      rule(:identifier) do
        tutorial_bundle |
          bundle_identifier |
          joint_with_iso_cie |
          joint_with_iso |
          joint_with_iec |
          identical_with_iso |
          dis_with_supplement |
          dual_with_iec |
          corrigendum_identifier |
          supplement_identifier |
          standard_with_language_year |
          legacy_code_with_year | # Before standard to catch 001-1980 pattern
          conference_identifier |
          standard_identifier
      end

      # Class method for parsing with preprocessing
      def self.parse(string)
        # Minimal preprocessing for data quality
        cleaned = string.strip

        # Remove comments (text after #)
        cleaned = cleaned.gsub(/\s*#.*$/, "")

        # Normalize spaces
        cleaned = cleaned.gsub(/\s+/, " ")

        # Insert missing colon before year in language patterns like /E2007 -> /E:2007
        # This is a data quality fix - correct format always has colon
        cleaned = cleaned.gsub(%r{/(E|F|G|DE|ES|CN|RU|FR)(\d{4})}, '/\1:\2')

        new.parse(cleaned)
      end
    end
  end
end
