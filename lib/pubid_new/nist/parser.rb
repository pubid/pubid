# frozen_string_literal: true

require "parslet"

module PubidNew
  module Nist
    # Parser class for NIST identifiers
    # Single Responsibility: Parsing NIST identifier syntax
    class Parser < Parslet::Parser
      # Class-level parse method with preprocessing
      # Handles data quality normalization before parsing
      def self.parse(input)
        # Normalize input
        cleaned = input.to_s.strip

        # Fix lowercase publisher at start
        cleaned = cleaned.sub(/^nbs\b/i, 'NBS')
        cleaned = cleaned.sub(/^nist\b/i, 'NIST')

        # Fix lowercase series (ir, sp, tn, etc.)
        cleaned = cleaned.sub(/\b(ir|sp|tn|hb|fips|ams|vts)\b/i) { |m| m.upcase }

        # Fix Roman numerals: "1011-I-2" → keep as is, but fix spaces: "1011-I-2 0" → "1011-I-2.0"
        cleaned = cleaned.gsub(/([-\d]+[IVX]+[-\d]+)\s+(\d+)/, '\1.\2')

        # Fix rev without space before year: "260-126rev2013" → "260-126 rev2013"
        cleaned = cleaned.gsub(/(\d)rev(\d{4})/, '\1 rev\2')

        # Fix LCIRC revision with slash and year: "145r6/1925" → "145 r6/1925"
        cleaned = cleaned.gsub(/(\d)(r\d+\/\d{4})/, '\1 \2')

        # Fix LCIRC supplement with slash and year: "118supp3/1926" → "118 supp3/1926"
        cleaned = cleaned.gsub(/(\d)(supp\d+\/\d{4})/, '\1 \2')

        # Fix Pt pattern: "800-57Pt3r1" → "800-57 pt3 r1"
        cleaned = cleaned.gsub(/(\d)Pt(\d+)(r\d+)/, '\1 pt\2 \3')

        # Fix version patterns: "ver1e2006" → "ver1 e2006", "ver2v1" → "ver2 v1"
        cleaned = cleaned.gsub(/(\d)ver(\d)/, '\1 ver \2')
        cleaned = cleaned.gsub(/ver(\d+)e(\d{4})/, 'ver\1 e\2')
        cleaned = cleaned.gsub(/ver(\d+)v(\d+)/, 'ver\1 v\2')

        # Fix dotted version: separate from number "268v1.1" → "268 v1.1"
        cleaned = cleaned.gsub(/(\d)(v\d+\.\d+)/, '\1 \2')

        # Fix volume ranges: "535v2a-l" → "535 v2a-l", "535v2m-z" → "535 v2m-z"
        cleaned = cleaned.gsub(/(\d)(v\d+[a-z]-[a-z])/, '\1 \2')

        # Fix spaces in version/volume numbers: "v1 1" → "v1.1", "1011-I-2 0" → "1011-I-2.0"
        cleaned = cleaned.gsub(/([v\d]+[-A-Z]*)\s+(\d+)/, '\1.\2')

        # Fix update patterns: ensure space before -upd or /upd (not just at end)
        cleaned = cleaned.gsub(/(\d+)-upd/, '\1 -upd')    # Match anywhere, not just end
        cleaned = cleaned.gsub(/(\d+)\/upd/, '\1 /upd')   # Slash variant
        cleaned = cleaned.gsub(/([a-z]\d+)\/upd/, '\1 /upd')  # After revision: r1/upd

        # Fix pd spacing: "800-140Br1 2pd" → "800-140B r1 2pd", " 3pd" → " 3 pd"
        cleaned = cleaned.gsub(/\s+(\d+)pd$/, ' \1 pd')

        # Fix "Suppl" with space: "955 Suppl" → "955Suppl"
        cleaned = cleaned.gsub(/(\d+)\s+Suppl\b/, '\1Suppl')

        # Fix number with space (when not handled above): "984 4" → "984_4"
        cleaned = cleaned.gsub(/(\d{3,})\s+(\d{1,2})$/, '\1_\2')

        # Detect format before parsing
        format = detect_format(input.to_s)

        # Use_parslet parser instance
        result = new.parse(cleaned)

        # Add format to result
        result.is_a?(Hash) ? result.merge(parsed_format: format) : result
      end

      # Detect format from input string
      # :mr if contains dots (machine-readable: NIST.SP.800-53)
      # :short otherwise (default: NIST SP 800-53)
      def self.detect_format(input)
        # Check if it has dot separators between publisher/series/number
        if input.match?(/^[A-Z]+\.[A-Z]+\.\d/)
          :mr
        else
          :short
        end
      end

      # Basic building blocks
      rule(:space) { str(" ") }
      rule(:dot) { str(".") }
      rule(:dash) { str("-") }
      rule(:slash) { str("/") }
      rule(:digit) { match("[0-9]") }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match("[A-Za-z]") }
      rule(:upper_letter) { match("[A-Z]") }
      rule(:lower_letter) { match("[a-z]") }

      # Hash prefix for machine-readable formats
      rule(:hash_prefix) { str("#") }

      # Month abbreviations
      rule(:month_abbrev) do
        str("January") | str("February") | str("March") | str("April") |
        str("May") | str("June") | str("July") | str("August") |
        str("September") | str("October") | str("November") | str("December") |
        str("Jan") | str("Feb") | str("Mar") | str("Apr") |
        str("Jun") | str("Jul") | str("Aug") | str("Sep") | str("Oct") | str("Nov") | str("Dec")
      end

      # Language codes for translations - 2-4 letter codes
      rule(:language_code) do
        (str("es") | str("pt") | str("chi") | str("viet") | str("port") | str("esp") |
         match("[a-z]").repeat(2, 4)).as(:translation)
      end

      # Stage ID: i (initial), f (final), 1-9 (numbered iterations)
      rule(:stage_id) do
        (str("i") | str("I") | str("f") | str("F") |
         str("1") | str("2") | str("3") | str("4") | str("5") |
         str("6") | str("7") | str("8") | str("9"))
      end

      # Stage type: pd (public draft), wd (work-in-progress), prd (preliminary)
      rule(:stage_type) do
        (str("pd") | str("PD") | str("wd") | str("WD") | str("prd") | str("PRD"))
      end

      # Old style stage: (IPD), (FPD), (2PD) - parenthetical at document start
      rule(:old_stage) do
        str("(") >> (stage_id.as(:stage_id) >> stage_type.as(:stage_type)).as(:stage) >> str(")")
      end

      # New style stage: " ipd", ".ipd" - inline at document end
      rule(:new_stage) do
        (space | dot) >> (stage_id.as(:stage_id) >> stage_type.as(:stage_type)).as(:stage)
      end

      # Publisher
      rule(:publisher) do
        (str("NBS") | str("NIST")).as(:publisher)
      end

      # Compound series (include publisher in series name) - must be checked FIRST
      rule(:compound_series) do
        (
          # Longest patterns first to avoid partial matches
          str("NBS BRPD-CRPL-D") | str("NBS CRPL-F-A") | str("NBS CRPL-F-B") |
          str("NBS CS-E") | str("CSRC Building Block") | str("CSRC Use Case") | str("CSRC Book") |
          str("ITL Bulletin") | str("NIST LC") | str("NIST PS") | str("NIST DCI") | str("NIST Other") |
          str("NSRDS-NBS") |
          # NBS and NIST specific patterns that conflict with simple series (shorter ones)
          str("NIST LCIRC") | str("NBS LCIRC") | str("NBS RPT") | # Added NIST LCIRC and NBS RPT
          str("NBS CSM") | str("NBS CIRC") | str("NBS CRPL") | str("NBS CS") |
          str("NBS CIS") | str("NBS HR") | str("NBS IRPL") | str("NBS IP") | str("NBS LC") | str("NBS PS") |
          str("NBS BH")
        ).as(:series)
      end

      # Simple series (no publisher prefix)
      rule(:simple_series) do
        (
          str("AMS") | str("VTS") |  # NEW - Added for NIST AMS and VTS series
          str("BSS") | str("BMS") | str("BH") |
          str("FIPS") | str("GCR") | str("HB") | str("MONO") |
          str("MP") | str("NCSTAR") | str("NSRDS") | str("IR") |
          str("SP") | str("TN") | str("CSWP") |
          str("AI") | str("CIRC") | str("CS") | str("CSM") |
          str("CRPL") | str("OWMWP") | str("PC") | str("RPT") |
          str("SIBS") | str("TIBM") | str("TTB") | str("EAB") |
          str("JPCRD") | str("JRES")
        ).as(:series)
      end

      # Number patterns - allow letters and digits, including edition patterns like "e2"
      # Suffix letter only if NOT followed by digit (prevents consuming 'e2', 'r1', etc.)
      # AND not followed by special keywords like 'sec', 'index', 'insert', 'errata'
      rule(:number_suffix) do
        match("[a-zA-Z]") >> (
          # Match suffixes
          str("ec") |
          str("ndex") |
          str("nsert") |
          str("rrata") |
          str("pp") |
          str("s") |
          str("t") |
          str("hi") |
          str("iet") |
          str("ort")).absent? >>
        digits.maybe
      end

      rule(:digits_with_suffix) do
        digits >>
          # Suffix only if not followed by digit (e.g., don't match 'e' in '140e2')
          (number_suffix >> digit.absent?).maybe
      end

      # Report number - first part - support edition prefixes like "e104" and supplement suffixes like "144supp"
      # Supplements should be handled as separate parts
      rule(:first_number) do
        (
          # Special text patterns - MOST SPECIFIC FIRST (NEW for RPT patterns)
          str("ADHOC") | (str("div") >> digits) |
          # Month ranges for RPT: Apr-Jun1948 (NEW)
          (month_abbrev >> dash >> month_abbrev >> digits) |
          # Roman numeral patterns: 1011-I-2.0, 1011-II-1.0 (ENHANCED to accept optional dots)
          (digits >> dash >> (str("III") | str("II") | str("IV") | str("I") | str("V") | str("VI") | str("VII") | str("VIII") | str("IX") | str("X")) >> dash >> digits >> (dot >> digits).maybe) |
          # GB series pattern: 1190GB-1, 1190GB-4A
          (digits >> str("GB") >> dash >> digits >> upper_letter.maybe) |
          # Volume-number format for CSM series: v6n1, v7n12
          (str("v") >> digits >> str("n") >> digits) |
          # Regular number with supplement and revision suffix: "154supprev"
          (digits >> str("supprev")) |
          # Regular number with edition, revision, and date: "13e2revJune1908"
          (digits >> str("e") >> digits >> str("rev") >> month_abbrev >> digits) |
          # Regular number with eN suffix and optional supplement (e.g., "101e2supp") - most specific
          (digits >> str("e") >> digits >> str("supp") >> digits.maybe) |
          # Edition prefix with revision and date: e2revJune1908
          (str("e") >> digits >> str("rev") >> month_abbrev >> digits) |
          # Edition prefix followed by digits and optional supplement with digits
          (str("e") >> digits >> str("supp") >> digits.maybe) |
          # Regular number with eN suffix (e.g., "101e2")
          (digits >> str("e") >> digits) |
          # Edition prefix followed by digits (e.g., "e104") - but NOT if followed by dash+digits (that's edition+year)
          (str("e") >> digits >> (dash >> digits).absent?) |
          # Letter prefix with digits (e.g., "c4" for CRPL)
          (lower_letter >> digits) |
          # Regular number with supplement suffix with month/year (e.g., "24suppJan1924")
          (digits >> str("supp") >> month_abbrev >> digits) |
          # Regular number with supplement suffix (e.g., "144supp") - with optional digits
          (digits >> str("supp") >> digits.maybe) |
          # Regular number with supplement suffix followed by month/year for date range
          (digits >> str("sup") >> month_abbrev >> digits) |
          # Regular number with "sp" suffix (e.g., "1088sp") - NEW for LCIRC patterns
          (digits >> str("sp")) |
          # Regular number with optional suffix (original) - includes letters like "A"
          digits_with_suffix
        ).as(:first_number)
      end

      # Second number (after dash) - allow pt suffix, letter suffixes, and CRPL patterns
      rule(:second_number) do
        (
          # CRPL range with underscore (e.g., "2_3-1A")
          (digits >> str("_") >> digits >> dash >> digits >> upper_letter.maybe) |
          # Letter followed by dash and digits (e.g., "m-5")
          (lower_letter >> dash >> digits) |
          # Number with pt suffix (e.g., "57pt1")
          (digits >> str("pt") >> digits) |
          # Special patterns like "NCNR", "PERMIS", "BFRL"
          str("NCNR") | str("PERMIS") | str("BFRL") |
          # Just capital letters (e.g., "A", "B") - NEW for RPT patterns
          upper_letter.repeat(1, 3) |
          # Regular number with optional suffix
          digits_with_suffix
        ).as(:second_number)
      end

      # Edition with different formats
      rule(:edition) do
        (
          # Date format with dash-month-day-slash-year: "11-1-Sep30/1977", "54-1-Jan15/1991"
          # This is actually a date pattern, not edition - treat the last part as a special date
          (dash >> digits.as(:part) >> dash >> month_abbrev.as(:date_month) >>
            digits.as(:date_day) >> slash >> digits.as(:date_year)).absent? >>
          # Edition with complex revision patterns: r1a, r2b
          ((str("r") | str(" R")) >> match("[0-9]").repeat(1, 2).as(:edition) >> lower_letter.as(:edition_letter)) |
          # Edition with revision and year: rev2013, rev2020
          (str("rev") >> digits.as(:edition_year)) |
          # Edition with revision and date: e2revJune1908, e3revJan1925
          ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >>
           str("rev") >> match("[A-Za-z]").repeat(3, 9).as(:edition_month) >> digits.as(:edition_year)) |
          # Edition with year and month: e201801, e2018 (4-digit year)
          (str("e") >> match("[0-9]").repeat(4, 4).as(:edition_year) >> match("[0-9]").repeat(2, 2).as(:edition_month).maybe) |
          # Edition number with dash and year: e2-1915, e3-2020
          ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >> dash >> digits.as(:edition_year)) |
          # Edition with dash and year/month: -2018, -Jan2018, -June1908, -April1909
          (dash >> (
            (match("[A-Za-z]").repeat(3, 9).as(:edition_month) >> digits.as(:edition_year)) |
           digits.as(:edition_year) |
            (match("[A-Za-z]").repeat(3, 3).as(:edition_month) >> match("[0-9]").repeat(2, 2).as(:edition_day) >>
              slash >> digits.as(:edition_year))
          )) |
          # Edition with e prefix and revision suffix: e2rev (edition 2 with revision)
          ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >> str("rev").as(:edition_has_rev).maybe) |
          # Edition with e prefix: e2, e3 (1-3 digits, NOT 4)
          ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition)) |
          # Revision-based edition: revJune1908, revJan1925
          (str("rev") >> match("[A-Za-z]").repeat(3, 9).as(:edition_month) >> digits.as(:edition_year))
        )
      end

      # CRPL range pattern (e.g., 1-2_3-1) - matches after first dash
      rule(:crpl_range) do
        (digits >> str("_") >> digits >> dash >> digits).as(:crpl_range)
      end

      # Full report number - support CRPL ranges
      rule(:report_number) do
        first_number >> (dash >> (crpl_range | second_number)).maybe
      end

      # Volume
      rule(:volume) do
        (space.maybe >> (str("v") | str(" Vol. "))) >>
        (digits >>
         (str("a-l") | str("m-z")).maybe >>  # NEW - Support volume ranges like v2a-l, v2m-z
         upper_letter.repeat(0, 2)).as(:volume)
      end

      # Part - enhanced to support patterns like p1adde1 (part 1 addition edition 1)
      rule(:part) do
        (str("pt") | str("p") | str("P") | str(" Part ")) >>
          (digits >>
           (str("add") >> (str("e") >> digits).maybe).maybe >>
           (dash >> digits).maybe).as(:part)
      end

      # Revision
      rule(:revision) do
        (
          # Revision with slash and year: r6/1925, r11/1924 (NEW for LCIRC patterns)
          (space.maybe >> (str("r") | str("rev")) >> digits.as(:revision) >>
           slash >> digits.as(:revision_year)) |
          # Revision with year: rev2013
          (str("rev") >> digits.as(:revision_year)) |
          # Revision with optional digits AND optional letter: r1a, ra, r1
          ((str(" rev ") | str("rev") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
            (digits.maybe >> lower_letter.maybe).as(:revision))
        )
      end

      # Version - V1 SP PARSER COMPATIBLE
      # Supports: ver1.0.2, ver2, " Ver. 2.0", " Version 1.0", v1.0.2, -v1.0
      rule(:version) do
        (
          # Verbose "ver" form - with or without dots (space.maybe before AND after "ver")
          (space.maybe >> str("ver") >> space.maybe >> (digits >> (dot >> digits).repeat).as(:version)) |
          # Verbose forms with space: " Ver. ", " Version " - require dots
          ((str(" Ver. ") | str(" Version ")) >>
            (digits >> dot >> digits >> (dot >> digits).maybe).as(:version)) |
          # Short form "v" with mandatory dots (v1.0, v1.0.2) - allow optional dash or space before
          ((dash | space).maybe >> str("v") >> (digits >> dot >> digits >> (dot >> digits).maybe).as(:version))
        )
      end

      # Update - V1 COMPATIBLE
      # Format: /Upd{N}-{YYYY}{MM} where MM is optional
      # Examples: /Upd1-2015, /Upd3-202102
      rule(:update) do
        (str("/Upd") | str("/upd") | space.maybe >> str("-upd")) >>
        (
          digits.as(:update_number) >>
          (dash >>
            match("[0-9]").repeat(4, 4).as(:update_year) >>
            match("[0-9]").repeat(2, 2).as(:update_month).maybe
          ).maybe
        ).as(:update)
      end

      # Addendum
      rule(:addendum) do
        ((str("-add") | str(".add") | str(" Add.")) >>
          (space | dash).maybe >> (digits | str("")).as(:addendum_number)).as(:addendum)
      end

      # Supplement - enhanced to support date patterns, year patterns, and combined with revision
      # Examples: suppJan1924, supp3/1926, supp1925, supJun1925-Jun1927 (date ranges), supprev
      rule(:supplement) do
        (str("supp") | str("sup")) >>
        (
          # Supplement followed by revision: supprev
          (str("rev")).as(:supplement_with_rev) |
          # Date range pattern: Jan1924-Jan1926
          (month_abbrev.as(:supp_month_start) >> digits.as(:supp_year_start) >>
           dash >> month_abbrev.as(:supp_month_end) >> digits.as(:supp_year_end)).as(:supplement_date_range) |
          # Month and year: Jan1924
          (month_abbrev.as(:supp_month) >> digits.as(:supp_year)).as(:supplement_date) |
          # Number with slash and year: 3/1926
          (digits.as(:supp_number) >> slash >> digits.as(:supp_year)).as(:supplement_slash_year) |
          # Just year: 1925
          digits.as(:supp_year) |
          # General suffix (other patterns)
          match("[A-Za-z0-9]").repeat(1).as(:supplement_suffix)
        ).maybe
      end

      # Errata
      rule(:errata) do
        (dash.maybe >> (str("errata") | str("err"))).as(:errata)
      end

      # Index
      rule(:index) do
        (str("index") | str("indx")).as(:index)
      end

      # Insert
      rule(:insert) do
        (str("insert") | str("ins")).as(:insert)
      end

      # Appendix
      rule(:appendix) do
        str("app").as(:appendix)
      end

      # Section - make digits optional for patterns like just "sec"
      rule(:section) do
        str("sec") >> digits.as(:section).maybe
      end

      # Translation (3-letter language code) - V1 COMPATIBLE
      # Supports: (spa), " spa", ".spa" (MR format)
      rule(:translation) do
        (
          # Parenthetical format: (spa), (por), (ind)
          (str("(") >> match('\w').repeat(3, 3).as(:translation) >> str(")")) |
          # Space-prefix format: " spa"
          (space >> match('\w').repeat(3, 3).as(:translation)) |
          # Dot-prefix format: ".spa" (machine-readable)
          (dot >> match('\w').repeat(3, 3).as(:translation))
        )
      end

      # Public draft suffix - for patterns like 2pd, 3pd
      rule(:pd_suffix) do
        (space >> digits >> str("pd")).as(:public_draft)
      end

      # Draft stage - enhanced to support suffix pattern
      rule(:draft) do
        (space >> str("(Draft)") | dash >> str("draft") | pd_suffix).as(:draft)
      end

      # Special date format with slash for FIPS (part of number, not edition)
      rule(:fips_date) do
        (dash >> digits.as(:fips_part) >> dash >> month_abbrev.as(:fips_month) >>
          digits.as(:fips_day) >> slash >> digits.as(:fips_year))
      end

      # All possible parts (order matters!)
      rule(:parts) do
        (
          # Put more specific patterns first
          # CRITICAL: new_stage BEFORE language_code to avoid "ipd" being treated as translation
          new_stage |
          section | index | insert | appendix | pd_suffix |
          edition | revision |
          version |  # MOVED BEFORE volume - try dotted versions (v1.1) before simple volumes (v1)
          volume | part | update | addendum |
          supplement | errata | language_code
        )
      end

      # Dot-separated machine-readable format: NIST.SP.800-116 or #NIST.2024-01-15.123
      # Enhanced to support parts after number like NIST.SP.1011-I-2.0
      rule(:mr_identifier) do
        hash_prefix.maybe >>
        publisher >> dot >>
        simple_series >> dot >>
        report_number >>
        (dot >> (digits | upper_letter)).repeat(0, 3) >>  # Support additional dot-separated parts
        (dash >> str("upd") >> digits.maybe).maybe >>
        parts.repeat >> draft.maybe
      end

      # Main identifier structure
      # Try compound series first (longest match), then publisher + simple series
      rule(:identifier) do
        mr_identifier |
        (
          # Compound series (includes publisher in series name)
          compound_series >> (space | dot) >>
          old_stage.maybe >>  # Old style stage after series
          report_number.maybe >> fips_date.maybe >> parts.repeat >> draft.maybe >> translation.maybe >> new_stage.maybe
        ) |
        (
          # Publisher + simple series - require space/dot between publisher and series
          publisher >> (space | dot) >>
          simple_series >>
          old_stage.maybe >>  # Old style stage after series
          (space | dot) >>
          report_number.maybe >> fips_date.maybe >> parts.repeat >> draft.maybe >> translation.maybe >> new_stage.maybe
        ) |
        (
          # Simple series only (no publisher)
          simple_series >>
          old_stage.maybe >>  # Old style stage after series
          (space | dot) >>
          report_number.maybe >> fips_date.maybe >> parts.repeat >> draft.maybe >> translation.maybe >> new_stage.maybe
        )
      end

      root(:identifier)
    end
  end
end