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
      rule(:publisher) do
        str("CSA") >> space >> (str("").as(:has_publisher) | str("0").as(:has_publisher))
      end

      # Code pattern: letter + dotted numbers (e.g., B149.1, C22.2, A123.17)
      # Can also have dash-number-letter suffix (e.g., for NO. numbers like 60950-1A)
      # Can have letter suffixes like HB, CIICHB, SP at the end
      # Can have multiple dash-number sequences (e.g., C13256-1-01)
      # NEW: Also support pure numbers with HB suffix (e.g., 15189HB)
      # NEW: Simple letter+number codes (e.g., Z240, A220) for Series identifiers
      rule(:code_pattern) do
        (
          # Pattern 1: Pure dotted numbers - e.g., 12.4, 2.15, 3.11
          (match("[0-9]").repeat(1) >> dot >> match("[0-9]").repeat(1) >>
           # Allow single-dash suffix for part numbers (e.g., "12.4-1")
           # But NOT 2-digit years which are handled separately
           (dash >> match("[0-9]").repeat(1)).repeat(0, 1) >>
           letter.repeat(2, 6).maybe).as(:code) |
          # Pattern 2: Pure numbers with HB suffix - e.g., 15189HB (NEW)
          (match("[0-9]").repeat(1) >> letter.repeat(2, 6)).as(:code) |
          # Pattern 3: Letter + numbers with dots then dashes - e.g., C22.2-144, B149.1
          (letter >> match("[0-9]").repeat(1) >>
           (dot >> match("[0-9]").repeat(1)).repeat >> # Dot sections first
           # Dash sections after - allow part numbers but not 2-digit years
           # Single digit dash = part number (e.g., "-1", "-2")
           # 3+ digits or letter suffix = part number (e.g., "-144", "-1A")
           # But DON'T consume 2-digit years which are matched separately
           (dash >> (
             (match("[0-9]") >> match("[0-9]").absent?) |  # exactly 1 digit (no digit follows)
             match("[0-9]").repeat(3) |  # 3+ digits = part number (e.g., "-144")
             (match("[0-9]").repeat(1) >> letter.repeat(1))  # digit + letter = part number (e.g., "-1A")
           )).repeat >>
           letter.repeat(2, 6).maybe).as(:code) | # Allow HB, CIICHB, SP, etc.
          # Pattern 4: Simple letter + number codes - e.g., Z240, A220, B140 (for Series)
          (letter >> match("[0-9]").repeat(1) >> dot >> match("[0-9]").repeat(1).maybe).as(:code) |
          # Pattern 5: Letter + multi-digit number without dots/dashes - e.g., Z240, A220
          (letter >> match("[0-9]").repeat(2,)).as(:code)
        )
      end

      # NO. notation - "Number" designation within a series (e.g., C22.2 NO. 1)
      rule(:no_notation) do
        space >> (str("NO.") | str("No.")).as(:no_notation) >> space
      end

      # Number after NO. - can be complex (e.g., 60601-1-9, 144.1, 1010.2.031, 1, 60601-1)
      # Note: Single-dash patterns allowed only when first part has 3+ digits
      # to avoid consuming year patterns like "1-04" where "-04" is the year
      rule(:no_number) do
        (
          # Multi-part with dashes (e.g., 60601-1-9, 1-9-2)
          # Requires at least 2 dashes (3+ numeric parts) to distinguish from year patterns
          (match("[0-9]").repeat(1) >>
           (dash >> match("[0-9]").repeat(1)).repeat(2, 10)) |
          # Single-dash pattern (e.g., 60601-1, 60079-11) - allowed if first part has 3+ digits
          # This prevents consuming year patterns like "1-04"
          # CRITICAL: 2-digit suffix allowed only when first part has 5+ digits
          # (IEC-style numbers like 60601, 60079). 3-4 digit first parts with 2-digit
          # suffixes are year patterns (e.g., "109-17" = number 109, year 2017).
          (match("[0-9]").repeat(5) >> dash >> match("[0-9]").repeat(1)) |  # 5+ digits: any suffix
          (match("[0-9]").repeat(3, 4) >> dash >> (
            (match("[0-9]") >> match("[0-9]").absent?) |  # exactly 1 digit (e.g., -1)
            match("[0-9]").repeat(3)  # 3+ digits (e.g., -144)
          )) |
          # Multi-part dotted number (e.g., 144.1, 1010.2.031, 1010.2.031.5)
          # Can have 1-3 dots (2-4 numeric parts)
          (match("[0-9]").repeat(1) >>
           (dot >> match("[0-9]").repeat(1)).repeat(1, 3)) |
          # Simple number (e.g., 1, 286)
          match("[0-9]").repeat(1)
        ).as(:no_number)
      end

      # Year format with optional F or M prefix
      rule(:year_prefix) { (str("F") | str("M")).as(:year_prefix).maybe }
      rule(:year_2digit) { digit.repeat(2, 2) }
      rule(:year_4digit) { digit.repeat(4, 4) }

      # Year with colon (modern format) - mark as colon_year
      # Support both with prefix (:M04) and without prefix (:04)
      rule(:colon_year) do
        str("").as(:colon_format) >>  # Mark that colon format was used
        colon >> (
          # With M/F prefix (e.g., :M04, :F04)
          (year_prefix >> (year_4digit | year_2digit).as(:year)) |
          # Without prefix (e.g., :04)
          (year_4digit | year_2digit).as(:year)
        )
      end

      # Year with dash (older format) - mark as dash_year
      # Support both with prefix (-M04) and without prefix (-04)
      rule(:dash_year) do
        str("").as(:dash_format) >>  # Mark that dash format was used
        dash >> (
          # With M/F prefix (e.g., -M04, -F04)
          (year_prefix >> (year_4digit | year_2digit).as(:year)) |
          # Without prefix (e.g., -04)
          (year_4digit | year_2digit).as(:year)
        )
      end

      # Reaffirmation notation - supports both 2-digit and 4-digit years
      # Tracks original format via :reaffirmation_4digit flag
      rule(:reaffirmation) do
        space >> str("(R") >>
          (year_4digit.as(:reaffirmation_4digit) | year_2digit.as(:reaffirmation_2digit)) >>
          str(")")
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
      # Pattern: CSA code [PREFIX] SERIES:year
      # Examples: CSA Z240 MH SERIES:16, CSA Z240 RV SERIES:23, CSA Z245.20 SERIES:22
      rule(:series_identifier) do
        publisher >>
          # Code comes first (can be letter+number or dotted numbers)
          (
            code_pattern |
            # Letter + multi-digit number for Series (e.g., Z240, A220, B139)
            (letter >> match("[0-9]").repeat(2,)).as(:code) |
            # Dotted numeric code (e.g., 245.20)
            (match("[0-9]").repeat(1) >> dot >> match("[0-9]").repeat(1)).as(:code)
          ) >>
          space >>
          # Optional series prefix (MH, RV, etc.) before SERIES keyword
          (series_prefix >> space).maybe >>
          series_keyword.as(:series_type) >>
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

      # ISO/IEC/CISPR/CEI adopted standards pattern
      # Examples:
      #   CSA ISO/IEC 9594-2:21
      #   CSA ISO/IEC TR 12785-3:15
      #   CSA CISPR 16-1-1:18
      #   CAN/CSA-ISO 10819:16
      #   CAN/CSA-IEC 62443-2-4:17
      #   CAN/CSA-CEI/IEC 61000-4-28-01
      rule(:adoption_identifier) do
        publisher.as(:adoption_pub) >>
          (
            # Option 1: ISO/IEC with TR/TS
            (str("ISO/IEC").as(:adoption_org) >> space >>
             (str("TR") | str("TS")).as(:iso_type) >> space >>
             match("[0-9-]").repeat(1).as(:adoption_number)) |
            # Option 1a: ISO/IEC without TR/TS (must come after TR/TS option in priority)
            (str("ISO/IEC").as(:adoption_org_with_type) >> space >>
             match("[0-9-]").repeat(1).as(:adoption_number)) |
            # Option 2: ISO alone
            (str("ISO").as(:adoption_org) >> space >>
             match("[0-9-]").repeat(1).as(:adoption_number)) |
            # Option 3: IEC alone
            (str("IEC").as(:adoption_org) >> space >>
             match("[0-9-]").repeat(1).as(:adoption_number)) |
            # Option 4: CEI/IEC (French name for IEC)
            (str("CEI/IEC").as(:adoption_org) >> space >>
             match("[0-9-]").repeat(1).as(:adoption_number)) |
            # Option 5: CISPR
            (str("CISPR").as(:adoption_org) >> space >>
             match("[0-9-]").repeat(1).as(:adoption_number))
          ) >>
          (colon | dash).as(:adoption_year_sep) >>
          (year_4digit | year_2digit).as(:adoption_year) >>
          (
            # Amendment with year: /A1:22 or /A1-22
            (slash >> str("A") >> digit.as(:adoption_amendment) >>
             (colon | dash) >> (year_4digit | year_2digit).as(:adoption_amendment_year))
          ).maybe >>
          reaffirmation.maybe
      end

      # Legacy: ISO/IEC TR/TS only pattern (for backward compatibility)
      rule(:iso_iec_adoption) do
        adoption_identifier
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
          amendment_slash.maybe # Add amendment support here
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
        publisher.as(:has_publisher).maybe >>
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
          str("").as(:comma_separator) # Mark as comma-based
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

        # Fix missing space before reaffirmation
        # Matches: XX(RYYYY), XXX(RYY), or any non-space chars before (R
        # Examples: 04(R2009) -> 04 (R2009), 16(R24) -> 16 (R24)
        normalized = normalized.gsub(/(\S)\(R(\d{2,4})\)/, '\1 (R\2)')

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
        # For combined_comma (has comma_separator), both first and second are full csa_code
        # For combined_slash (no comma_separator), second is continuation that may have has_publisher
        if hash[:second] && (hash[:comma_separator] || hash[:second][:has_publisher])
          hash[:second][:publisher_prefix] = prefix
        end
        if hash[:third] && hash[:third][:has_publisher]
          hash[:third][:publisher_prefix] =
            prefix
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
