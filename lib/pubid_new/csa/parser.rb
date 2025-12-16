# frozen_string_literal: true

require "parslet"

module PubidNew
  module Csa
    class Parser < Parslet::Parser
      # Basic building blocks
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:slash) { str("/") }
      rule(:colon) { str(":") }
      rule(:comma) { str(",") }
      rule(:dot) { str(".") }
      rule(:ampersand) { str("&") }
      rule(:digit) { match("[0-9]") }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match("[A-Z]") }
      rule(:letters) { letter.repeat(1) }

      # Publisher
      rule(:publisher) { str("CSA") >> space }

      # Code pattern: letter + dotted numbers (e.g., B149.1, C22.2, A123.17)
      # Can also have dash-number-letter suffix (e.g., for NO. numbers like 60950-1A)
      # Can have letter suffixes like HB, CIICHB, SP at the end
      rule(:code_pattern) do
        (
          letter >> match("[0-9]").repeat(1) >>
          (dot >> match("[0-9]").repeat(1)).repeat >>
          (dash >> match("[0-9]").repeat(1) >> letter).maybe >>
          letter.repeat(2, 6).maybe  # Allow HB, CIICHB, SP, etc.
        ).as(:code)
      end

      # NO. keyword (for C22.2 NO. 286 pattern)
      rule(:no_keyword) { space >> str("NO") >> dot >> space }

      # Number after NO. keyword - can have letter suffix like "60950-1A"
      # can have SP suffix, and optional year after
      rule(:no_number) do
        match("[0-9]").repeat(1) >>
        (dash >> match("[0-9]").repeat(1) >> letter.maybe).repeat >>
        letter.repeat(2, 6).maybe >>  # Allow SP suffix
        (dash >> year_2digit.as(:no_year)).maybe
      end

      rule(:no_portion) do
        no_keyword >> no_number.as(:no_number)
      end

      # Year format with optional F or M prefix
      rule(:year_prefix) { (str("F") | str("M")).as(:year_prefix).maybe }
      rule(:year_2digit) { digit.repeat(2, 2) }
      rule(:year_4digit) { digit.repeat(4, 4) }

      # Year with colon (modern format) - mark as colon_year
      rule(:colon_year) do
        colon >> year_prefix >> (year_4digit | year_2digit).as(:year) >> str("").as(:colon_format)
      end

      # Year with dash (older format) - mark as dash_year
      rule(:dash_year) do
        dash >> year_prefix >> (year_4digit | year_2digit).as(:year) >> str("").as(:dash_format)
      end

      # Reaffirmation notation
      rule(:reaffirmation) do
        space >> str("(R") >> year_4digit.as(:reaffirmation) >> str(")")
      end

      # Amendment notation (e.g., /A1:15, /A2:22, /Amd 1)
      rule(:amendment_slash) do
        slash >>
        (str("Amd") >> space).maybe >>
        str("A").maybe >>
        digits.as(:amendment_number) >>
        (colon >> year_2digit.as(:amendment_year)).maybe
      end

      # Package keywords
      rule(:package_keyword) do
        (
          str("Code") | str("Handbook") | str("Training Package") | str("Package")
        )
      end

      # Package portion: "Code, Handbook & Training Package"
      rule(:package_portion) do
        space >>
        package_keyword >>
        (
          (comma >> space >> package_keyword) |
          (space >> ampersand >> space >> package_keyword)
        ).repeat
      end

      # Series prefix: 2-3 letters before SERIES keyword (e.g., MH, RV)
      rule(:series_prefix) do
        letter.repeat(2, 3).as(:series_prefix)
      end

      # SERIES keyword - just the word, don't consume the delimiter
      rule(:series_keyword) do
        str("SERIES")
      end

      # ISO/IEC adopted standards pattern: CSA ISO/IEC TR 19758:04 (R2024)
      rule(:iso_iec_adoption) do
        publisher >>
        str("ISO/IEC") >> space >>
        (str("TR") | str("TS")).as(:iso_type) >> space >>
        match("[0-9-]").repeat(1).as(:iso_number) >>
        colon >> year_2digit.as(:year) >>
        (slash >> str("A") >> digit.as(:iso_amendment)).maybe >>
        reaffirmation.maybe
      end

      # Basic CSA identifier
      rule(:csa_code) do
        publisher >>
        code_pattern >>
        no_portion.maybe >>
        (
          # Option 1: series with prefix (space + prefix + space + keyword + year)
          (space >> series_prefix >> space >> series_keyword >> (colon_year | dash_year)) |
          # Option 2: series without prefix (space + keyword + year)
          (space >> series_keyword >> (colon_year | dash_year)) |
          # Option 3: just year (no series)
          (colon_year | dash_year)
        ).maybe >>
        amendment_slash.maybe  # Add amendment support here
      end

      # Combined CSA standards with slash
      rule(:combined_slash) do
        csa_code.as(:first) >>
        slash >>
        csa_code.as(:second) >>
        (slash >> csa_code.as(:third)).maybe >>  # Allow triple combined
        reaffirmation.maybe >>
        package_portion.maybe
      end

      # Combined with comma (CSA B149.1:25, CSA B149.2:25)
      rule(:combined_comma) do
        csa_code.as(:first) >>
        comma >> space >>
        csa_code.as(:second) >>
        reaffirmation.maybe >>
        (space >> ampersand >> package_portion).maybe
      end

      # Single identifier with optional package
      rule(:single_identifier) do
        csa_code >>
        reaffirmation.maybe >>
        package_portion.maybe
      end

      # Main identifier
      rule(:identifier) do
        iso_iec_adoption | combined_slash | combined_comma | single_identifier
      end

      root(:identifier)

      # Preprocessing to normalize input
      def parse(input)
        # Remove CONSOLIDATED notation
        normalized = input.gsub(/\s*\(\s*CONSOLIDATED\s*\)\s*/, " ")
        # Clean up extra spaces
        normalized = normalized.gsub(/\s+/, " ").strip
        super(normalized)
      end
    end
  end
end