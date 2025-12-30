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
      rule(:plus) { str(" + ") }
      rule(:digit) { match("[0-9]") }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match("[A-Z]") }
      rule(:letters) { letter.repeat(1) }

      # Publisher
      rule(:publisher) { str("CSA") >> space }

      # Code pattern: letter + dotted numbers (e.g., B149.1, C22.2, A123.17)
      # Can also have dash-number-letter suffix (e.g., for NO. numbers like 60950-1A)
      # Can have letter suffixes like HB, CIICHB, SP at the end
      # Can have multiple dash-number sequences (e.g., C13256-1-01)
      # NEW: Also support pure numbers with HB suffix (e.g., 15189HB)
      rule(:code_pattern) do
        (
          # Pattern 1: Pure dotted numbers - e.g., 12.4, 2.15, 3.11
          (match("[0-9]").repeat(1) >> dot >> match("[0-9]").repeat(1) >>
           (dash >> match("[0-9]").repeat(1)).repeat >>  # Allow multiple dash sequences
           letter.repeat(2, 6).maybe).as(:code) |
          # Pattern 2: Pure numbers with HB suffix - e.g., 15189HB (NEW)
          (match("[0-9]").repeat(1) >> letter.repeat(2, 6)).as(:code) |
          # Pattern 3: Letter + numbers with dots then dashes - e.g., C22.2-144, B149.1
          (letter >> match("[0-9]").repeat(1) >>
           (dot >> match("[0-9]").repeat(1)).repeat >>  # Dot sections first
           # Dash sections after - but don't consume 2-digit years (require 3+ digits OR letter suffix)
           (dash >> (match("[0-9]").repeat(3) | (match("[0-9]").repeat(1, 2) >> letter.repeat(1)))).repeat >>
           letter.repeat(2, 6).maybe).as(:code)  # Allow HB, CIICHB, SP, etc.
        )
      end

      # NO. notation - "Number" designation within a series (e.g., C22.2 NO. 1)
      rule(:no_notation) do
        space >> (str("NO.") | str("No.")).as(:no_notation) >> space
      end

      # Number after NO. - can be complex (e.g., 60601-1-9, 144.1, 1)
      rule(:no_number) do
        (
          # Multi-part with dashes (e.g., 60601-1-9)
          (match("[0-9]").repeat(1) >> (dash >> match("[0-9]").repeat(1)).repeat(1)) |
          # Dotted number (e.g., 144.1)
          (match("[0-9]").repeat(1) >> dot >> match("[0-9]").repeat(1)) |
          # Simple number (e.g., 1, 286)
          match("[0-9]").repeat(1)
        ).as(:no_number)
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

      # Series identifier - SERIES as PRIMARY type (not modifier)
      # Pattern: CSA [PREFIX] SERIES code:year
      # Examples: CSA MH SERIES 3.14:20, CSA SERIES Z1000:22
      rule(:series_identifier) do
        publisher >>
        (series_prefix >> space).maybe >>
        series_keyword.as(:series_type) >> space >>
        # Allow either standard code_pattern OR numeric-only codes (e.g., 3.14, 1)
        (
          code_pattern |
          (match("[0-9]").repeat(1) >> (dot >> match("[0-9]").repeat(1)).repeat).as(:code)
        ) >>
        (colon_year | dash_year) >>
        reaffirmation.maybe
      end

      # CEC (Canadian Electrical Code) identifier
      # Pattern: CSA C22.{2,3,4,6} NO. {number}:{year}
      # Examples: CSA C22.2 NO. 286:23, CSA C22.3 NO. 7:20
      # The "NO." notation is a semantic component and must be preserved
      rule(:cec_identifier) do
        publisher >>
        (
          str("C22.2") | str("C22.3") | str("C22.4") | str("C22.6")
        ).as(:cec_part) >>
        no_notation >>
        no_number >>
        (colon_year | dash_year) >>
        reaffirmation.maybe
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
        (
          # Option 1: NO. notation (e.g., C22.2 NO. 1:20)
          (no_notation >> no_number >> (colon_year | dash_year)) |
          # Option 2: series with prefix (space + prefix + space + keyword + year)
          (space >> series_prefix >> space >> series_keyword.as(:series) >> (colon_year | dash_year)) |
          # Option 3: series without prefix (space + keyword + year)
          (space >> series_keyword.as(:series) >> (colon_year | dash_year)) |
          # Option 4: just year (no series, no NO.)
          (colon_year | dash_year)
        ) >>
        amendment_slash.maybe  # Add amendment support here
      end

      # Base CSA code without amendment (for combined identifiers)
      rule(:base_csa_code) do
        publisher >>
        code_pattern >>
        (
          # Option 1: NO. notation
          (no_notation >> no_number >> (colon_year | dash_year)) |
          # Option 2: series with prefix
          (space >> series_prefix >> space >> series_keyword.as(:series) >> (colon_year | dash_year)) |
          # Option 3: series without prefix
          (space >> series_keyword.as(:series) >> (colon_year | dash_year)) |
          # Option 4: just year
          (colon_year | dash_year)
        )
      end

      # Continuation code (optional CSA publisher prefix, for combined identifiers)
      rule(:continuation_code) do
        (publisher.as(:has_publisher)).maybe >>
        code_pattern >>
        (
          # Option 1: NO. notation
          (no_notation >> no_number >> (colon_year | dash_year)) |
          # Option 2: series with prefix
          (space >> series_prefix >> space >> series_keyword.as(:series) >> (colon_year | dash_year)) |
          # Option 3: series without prefix
          (space >> series_keyword.as(:series) >> (colon_year | dash_year)) |
          # Option 4: just year
          (colon_year | dash_year)
        ) >>
        amendment_slash.maybe
      end

      # Bundled portion - code that follows + (base is implied, no CSA prefix)
      # Example: "A2:22" in "CSA C22.2 NO. 60601-1:14 + A2:22"
      rule(:bundled_portion) do
        code_pattern >>
        (
          # Option 1: NO. notation
          (no_notation >> no_number >> (colon_year | dash_year).maybe) |
          # Option 2: just year or no year
          (colon_year | dash_year).maybe
        )
      end

      # Bundled identifier with + notation (consolidated documents)
      rule(:bundled_identifier) do
        csa_code.as(:base) >>
        plus >>
        bundled_portion.as(:bundled_first) >>
        (plus >> bundled_portion).repeat.as(:bundled_rest) >>
        reaffirmation.maybe
      end

      # Combined CSA standards with slash
      rule(:combined_slash) do
        base_csa_code.as(:first) >>
        slash >>
        continuation_code.as(:second) >>
        (slash >> continuation_code.as(:third)).maybe >>
        reaffirmation.maybe >>
        package_portion.maybe
      end

      # Combined with comma (CSA B149.1:25, CSA B149.2:25)
      rule(:combined_comma) do
        csa_code.as(:first) >>
        comma >> space >>
        csa_code.as(:second) >>
        reaffirmation.maybe >>
        (
          (space >> ampersand >> package_portion) |
          package_portion
        ).as(:package_portion).maybe >>
        str("").as(:comma_separator)  # Mark as comma-based
      end

      # Single identifier with optional package
      rule(:single_identifier) do
        csa_code >> reaffirmation.maybe >> package_portion.as(:package_portion).maybe
      end

      # Code-only identifier (no CSA prefix) - try this last
      rule(:code_only_identifier) do
        code_pattern >>
        (
          # Option 1: series with prefix
          (space >> series_prefix >> space >> series_keyword.as(:series) >> (colon_year | dash_year)) |
          # Option 2: series without prefix
          (space >> series_keyword.as(:series) >> (colon_year | dash_year)) |
          # Option 3: just year
          (colon_year | dash_year)
        ) >>
        (space >> str("PACKAGE")).as(:package_portion).maybe
      end

      # Main identifier
      rule(:identifier) do
        iso_iec_adoption | series_identifier | cec_identifier | bundled_identifier | combined_slash | combined_comma | single_identifier | code_only_identifier
      end

      root(:identifier)

      # Preprocessing to normalize input
      def parse(input)
        # Skip comment lines
        raise Parslet::ParseFailed.new("Comment line") if input.strip.start_with?("#")

        # Remove CONSOLIDATED notation FIRST (before other processing)
        normalized = input.gsub(/\s*\(\s*CONSOLIDATED\s*\)\s*/, " ")
        normalized = normalized.gsub(/\s*\bCONSOLIDATED\b\s*/, " ")

        # Fix missing space before reaffirmation: 94(R04) -> 94 (R04)
        normalized = normalized.gsub(/(\d{2})\(R(\d{2,4})\)/, '\1 (R\2)')

        # DO NOT normalize NO., let it be parsed as a separate identifier component

        # Normalize CEI/IEC to IEC (CEI is French name for IEC)
        normalized = normalized.gsub(/CEI\/IEC/, "IEC")
        normalized = normalized.gsub(/\bCEI\b/, "IEC")

        # Track original publisher prefix
        publisher_prefix = if normalized.start_with?("CAN/CSA-")
                            "CAN/CSA-"
                          elsif normalized.start_with?("CAN3-")
                            "CAN3-"
                          elsif normalized.start_with?("CSA ")
                            "CSA"
                          else
                            nil
                          end

        # Normalize CAN/CSA- and CAN3- to CSA (preserving space before code)
        normalized = normalized.gsub("CAN/CSA-", "CSA ")
        normalized = normalized.gsub("CAN3-", "CSA ")

        # Clean up extra spaces
        normalized = normalized.gsub(/\s+/, " ").strip

        # Parse and inject publisher_prefix into result
        result = super(normalized)

        # Inject publisher_prefix if we have one
        if publisher_prefix && result.is_a?(Hash)
          inject_publisher_prefix(result, publisher_prefix)
        end

        result
      end

      private

      def inject_publisher_prefix(hash, prefix)
        # For combined identifiers
        if hash[:first]
          hash[:first][:publisher_prefix] = prefix
        end
        if hash[:second]
          # For combined_comma (has comma_separator), both first and second are full csa_code
          # For combined_slash (no comma_separator), second is continuation that may have has_publisher
          if hash[:comma_separator] || hash[:second][:has_publisher]
            hash[:second][:publisher_prefix] = prefix
          end
        end
        if hash[:third]
          hash[:third][:publisher_prefix] = prefix if hash[:third][:has_publisher]
        end

        # For bundled identifiers
        if hash[:base]
          inject_publisher_prefix(hash[:base], prefix)
        end

        # For single identifiers (no :first, no :base, just raw attributes)
        if !hash[:first] && !hash[:base] && !hash[:bundled_first]
          hash[:publisher_prefix] = prefix
        end

        hash
      end
    end
  end
end