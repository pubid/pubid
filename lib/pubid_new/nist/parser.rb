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
        cleaned = cleaned.sub(/^nbs\b/i, "NBS")
        cleaned = cleaned.sub(/^nist\b/i, "NIST")

        # Fix lowercase series (ir, sp, tn, etc.)
        cleaned = cleaned.sub(/\b(ir|sp|tn|hb|fips|ams|vts)\b/i) do |m|
          m.upcase
        end

        # Fix Roman numerals: "1011-I-2" → keep as is, but fix spaces: "1011-I-2 0" → "1011-I-2.0"
        cleaned = cleaned.gsub(/([-\d]+[IVX]+[-\d]+)\s+(\d+)/, '\1.\2')

        # Fix rev without space: "126rev2013" → "126 rev2013" (separate number from rev+year)
        # BUT preserve edition+revision patterns: "e2rev1908" stays as-is
        cleaned = cleaned.gsub(/(?<!e)(\d)(rev\d{4})/, '\1 \2')

        # Fix LCIRC revision with slash and year: "145r6/1925" → "145 r6/1925"
        cleaned = cleaned.gsub(/(\d)(r\d+\/\d{4})/, '\1 \2')

        # Fix LCIRC revision with just year (no slash): "1128r1995" → "1128 r1995"
        # BUT preserve edition+revision patterns: "13e2rev1908" stays as-is
        cleaned = cleaned.gsub(/(?<!e\d)(r\d{4})/, ' \1')

        # Fix month in revision: "4743rJun1992" → "4743 rJun1992" (NEW)
        cleaned = cleaned.gsub(/(\d)(r[A-Z][a-z]{2,8}\d{4})/, '\1 \2')
        # NEW FIX 1: Revision with 1-2 digits + lowercase letter: "800-22r1a" → "800-22 r1A"
        # Capture parts separately to avoid interpolation issues
        cleaned = cleaned.gsub(/(\d)(r)(\d{1,2})([a-z])\b/) do
          num = $1
          r_prefix = $2
          rev_num = $3
          letter = $4.upcase
          "#{num} #{r_prefix}#{rev_num}#{letter}"
        end

        # CRITICAL: Normalize lowercase letter suffix to uppercase
        # Fix dash-letter pattern: "6529-a" → "6529-A" (FIXED - was incorrect)
        cleaned = cleaned.gsub(/(\d)-([a-z])$/) { "#{$1}-#{$2.upcase}" }

        # Fix direct letter suffix (no dash): "378g" → "378G", "1000a" → "1000A"
        # MUST come after dash pattern to avoid conflicts
        # Only match single letter at end, not part of words like "index", "sec", etc.
        cleaned = cleaned.gsub(/(\d)([a-z])$/) { "#{$1}#{$2.upcase}" }

        # Fix space before volume number: "80-2073 2" → "80-2073 v2" (Session 219)
        # This handles NBS IR 80-2073 2 and NBS IR 80-2073 3 as volume identifiers
        cleaned = cleaned.gsub(/(\d{2}-\d{4})\s+(\d)$/, '\1 v\2')

        # Fix draft with number: "8270-draft2" → "8270 -draft 2" (Session 253)
        # Space BEFORE dash AND after draft to separate it from report_number
        cleaned = cleaned.gsub(/(\d)-draft(\d)/, '\1 -draft \2')

        # NEW FIX 2: Draft without dash: "8270draft2" → "8270 -draft 2"
        # More lenient pattern to catch missing dash before draft
        cleaned = cleaned.gsub(/(\d)draft(\d)/, '\1 -draft \2')

        # Fix supplement typo: "154suprev" → "154supprev" (Session 219)
        cleaned = cleaned.gsub(/(\d)suprev/, '\1supprev')

        # Fix letter suffix + revision before draft: "140Cr1-draft2" → "140C r1-draft2" (Session 221)
        # Must be BEFORE general draft preprocessing at line 47
        cleaned = cleaned.gsub(/(\d{2,})([A-Z])(r\d+)([-\s]draft\d*)/,
                               '\1\2 \3\4')

        # Convert Roman numeral volumes to Arabic per NIST spec (page 7)
        # "1011-I-2.0" → "1011 v1 ver2.0"
        # "1011-II-1.0" → "1011 v2 ver1.0"
        cleaned = cleaned.gsub(/(\d+)-([IVX]+)-(\d+(?:\.\d+)*)/) do
          number = $1
          roman = $2
          version_part = $3

          # Convert Roman to Arabic
          arabic = roman_to_arabic(roman)

          # Convert to volume+version format
          "#{number} v#{arabic} ver#{version_part}"
        end

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

        # CRITICAL: Now separate dotted versions from preceding digits: "268v1.1" → "268 v1.1" (NEW)
        cleaned = cleaned.gsub(/(\d)(v\d+\.\d+)/, '\1 \2')

        # NEW: Separate version from number AND convert spaces to dots in one step
        cleaned = cleaned.gsub(/(\d)(v\d+)\s+(\d+)$/, '\1 \2.\3')               # Two-part: "268v1 1" → "268 v1.1"
        cleaned = cleaned.gsub(/(\d)(v\d+)\s+(\d+)\s+(\d+)$/, '\1 \2.\3.\4')    # Three-part: "63v1 0 1" → "63 v1.0.1"

        # Fix volume ranges: "535v2a-l" → "535 v2a-l", "535v2m-z" → "535 v2m-z"
        cleaned = cleaned.gsub(/(\d)(v\d+[a-z]-[a-z])/, '\1 \2')

        # NEW: Fix volume with uppercase letter: "48v3B" → "48 v3B" (Session 220)
        cleaned = cleaned.gsub(/(\d)(v\d+[A-Z])/, '\1 \2')

        # NEW: Fix volume ranges with uppercase: "v2A-L" → "v2a-l" (normalize to lowercase) (Session 220)
        cleaned = cleaned.gsub(/(v\d+)([A-Z])-([A-Z])/, '\1\2-\3'.downcase)

        # CRITICAL: Fix revision attached to number BEFORE update patterns!
        # "8115r1-upd" → "8115 r1-upd" so that later "r1-upd" → "r1 -upd" works
        # But preserve r6/1925 format (don't add space before slash/year)
        # And preserve 300-8r1/upd format (don't separate r1/upd)
        # ENHANCED: Also handle r1a (revision with letter suffix) - "800-22r1a" → "800-22 r1A"
        cleaned = cleaned.gsub(/(\d)(r\d+)([a-z]?)(?=-|[A-Z]|$)/) do
          num = $1
          rev = $2
          letter = $3
          # Uppercase the trailing letter if present
          letter_fixed = letter.empty? ? "" : letter.upcase
          "#{num} #{rev}#{letter_fixed}"
        end

        # Fix spaces in version/volume numbers: "v1 1" → "v1.1", "1011-I-2 0" → "1011-I-2.0"
        # ENHANCED to handle multiple spaces: "v1 0 1" → "v1.0.1", "v1 0 2" → "v1.0.2"
        cleaned = cleaned.gsub(/([v\d]+[-A-Z]*)\s+(\d+)\s+(\d+)/, '\1.\2.\3')  # Three parts
        cleaned = cleaned.gsub(/([v\d]+[-A-Z]*)\s+(\d+)/, '\1.\2')             # Two parts

        # Fix update patterns: ensure space before -upd or /upd (not just at end)
        # Enhanced to handle optional digits after upd: -upd, -upd1, /upd, /upd1
        cleaned = cleaned.gsub(/(\d+)-upd(\d*)/, '\1 -upd\2')    # -upd or -upd1
        cleaned = cleaned.gsub(/(\d+)\/upd(\d*)/, '\1 /upd\2')   # /upd or /upd1
        cleaned = cleaned.gsub(/([a-z]\d+)-upd/, '\1 -upd')      # r1-upd → r1 -upd
        cleaned = cleaned.gsub(/([a-z]\d+)\/upd/, '\1 /upd')     # After revision: r1/upd → r1 /upd

        # NEW FIX 3: MR format with letter suffix before update: "8286C-upd1" → "8286C -upd1"
        # Must handle uppercase letters before -upd in MR format
        cleaned = cleaned.gsub(/(\d+[A-Z])-upd(\d*)/, '\1 -upd\2')  # Letter suffix + update
        cleaned = cleaned.gsub(/(\d+[A-Z])\/upd(\d*)/, '\1 /upd\2') # Letter suffix + /upd variant

        # Fix supplement patterns: ensure space before supplement (1st variant)
        # "118supp3" already handled at line 32-33, but add "sup" variant
        cleaned = cleaned.gsub(/(\d)(sup\d)/, '\1 \2') # 100-2sup1 → 100-2 sup1
        # Fix supplement patterns: ensure space before supplement (2nd variant)
        cleaned = cleaned.gsub(/(\d)(sup+)(\d)/, '\1 \2\3') # 100-2sup+1 → 100-2 sup+1
        # Fix supplement patterns: ensure space before supplement (3rd variant)
        cleaned = cleaned.gsub(/(\d)(sup\+)(\d)/, '\1 \2\3') # 100-2sup+1 → 100-2 sup+1
        # Fix supplement patterns: ensure space before supplement (4th variant)
        cleaned = cleaned.gsub(/(\d)(sup\d+)/, '\1 \2') # 100-2sup1 → 100-2 sup1
        # Fix supplement patterns: ensure space before supplement (5th variant)
        cleaned = cleaned.gsub(/(\d)(sup\d+\b)/, '\1 \2') # 100-2sup1 → 100-2 sup1

        # Fix revision letter patterns: ensure space before revision with letter
        cleaned = cleaned.gsub(/(\d)(r\d+[a-z])/, '\1 \2')       # 800-22r1a → 800-22 r1a
        cleaned = cleaned.gsub(/(\d)(r[a-z]+\b)/, "\1 \2")       # 800-27ra → 800-27 ra (one or more letters)

        # Fix number with letter suffix followed by standalone 'r': "56ar" → "56a r" (NEW)
        cleaned = cleaned.gsub(/(\d[a-z])r\b/, '\1 r')

        # Fix revision followed by language code: "r1es" → "r1 es", "r1pt" → "r1 pt" (NEW)
        cleaned = cleaned.gsub(/(r\d+)(es|pt|chi|viet|port|esp)\b/, '\1 \2')

        # ENHANCEMENT 1: Edition year normalization (-YYYY → eYYYY)
        # Per NIST spec, trailing -YYYY should normalize to eYYYY format
        # Pattern: number (optionally with non-e letter suffix) followed by dash and 4-digit year
        # Examples: "330-2019" → "330e2019", "304a-2017" → "304Ae2017"
        # Must NOT match existing edition patterns like "11e2-1915" (e2 is edition, -1915 is separate)
        # Must be at end or before space to avoid breaking number-number patterns like "800-53"
        cleaned = cleaned.gsub(/(\d(?:[A-DF-Z]?))-(\d{4})(?=\s|$)/, '\1e\2')

        # ENHANCEMENT 2: Version normalization (v1.1 → ver1.1, Ver. 2.0 → ver2.0)
        # Normalize short v format to verbose ver format per NIST spec
        # Already handled in version rule, but normalize in preprocessing for consistency
        # Handle Ver. with period: "Ver. 2.0" → "ver2.0" (remove period and space)
        cleaned = cleaned.gsub(/\bVer\.\s+(\d+(?:\.\d+)*)/, 'ver\1')
        # Handle verbose "v" to "ver": "v1.1" → "ver1.1" (only with dots - versions have dots)
        cleaned = cleaned.gsub(/\bv(\d+\.\d+(?:\.\d+)*)/, 'ver\1')

        # Fix uppercase P for part: "428P1" → "428 p1", "647P2" → "647 p2" (NEW)
        cleaned = cleaned.gsub(/(\d)P(\d)/, '\1 p\2')

        # Normalize part notation: "p1" → "pt1", "n1" → "pt1" for consistency
        # This handles patterns like "61p1" → "61pt1" and "467n1" → "467pt1"
        # MUST come AFTER uppercase P normalization
        cleaned = cleaned.gsub(/\b([pn])(\d+)/, 'pt\2')

        # Fix complex part patterns in MR format: ensure space before part
        cleaned = cleaned.gsub(/(\d)([pP]\d+)/, '\1 \2') # .467p1adde1 → .467 p1adde1, 800-57p1 → 800-57 p1

        # Extract volume from number: "17-917v3" → "17-917 v3", "1-1v1" → "1-1 v1"
        # Pattern: digits-digits followed by v and digits (GCR, NCSTAR patterns)
        # MUST be specific to avoid breaking existing "v1.1" patterns
        cleaned = cleaned.gsub(/(\d+-\d+)(v\d+)(?![.\d])/, '\1 \2') # Negative lookahead for dots

        # Fix pd spacing: "800-140Br1 2pd" → "800-140B r1 2pd", " 3pd" → " 3 pd"
        cleaned = cleaned.gsub(/\s+(\d+)pd$/, ' \1 pd')

        # Fix "Suppl" with space: "955 Suppl" → "955Suppl"
        cleaned = cleaned.gsub(/(\d+)\s+Suppl\b/, '\1Suppl')

        # Fix verbose "Version" format: " Version 2" → " ver 2"
        cleaned = cleaned.gsub(/\s+Version\s+(\d+)/, ' ver \1')

        # Fix verbose "Revision" format: " Revision (r)" → " r"
        cleaned = cleaned.gsub(/\s+Revision\s+\(r\)/, " r")

        # REMOVED: Incorrect dot preprocessing that treated dots as number separators
        # This was semantically wrong - dots are PART separators in NIST!
        # DELETE: cleaned = cleaned.gsub(/(\d{3,})\.(\d{1,4})(?=\s|$)/, '\1_\2')

        # REMOVED: Incorrect space-to-underscore that treated as single number
        # DELETE: cleaned = cleaned.gsub(/(\d{3,})\s+(\d{1,2})$/, '\1_\2')

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

      # Convert Roman numerals to Arabic numbers
      # I→1, II→2, III→3, IV→4, V→5, VI→6, VII→7, VIII→8, IX→9, X→10
      def self.roman_to_arabic(roman)
        case roman
        when "I" then "1"
        when "II" then "2"
        when "III" then "3"
        when "IV" then "4"
        when "V" then "5"
        when "VI" then "6"
        when "VII" then "7"
        when "VIII" then "8"
        when "IX" then "9"
        when "X" then "10"
        else roman # Fallback for unexpected patterns
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
        (space.maybe >> (str("es") | str("pt") | str("chi") | str("viet") | str("port") | str("esp") |
         match("[a-z]").repeat(2, 4))).as(:translation)
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
          str("ITL Bulletin") | str("NSRDS-NBS") |
          # NBS and NIST specific patterns that conflict with simple series
          # CRITICAL: Put longer patterns before shorter to avoid partial matches!
          str("NIST LCIRC") | str("NBS LCIRC") | str("NBS RPT") |
          str("NIST LC") | str("NIST PS") | str("NIST DCI") | str("NIST Other") |
          str("NBS CSM") | str("NBS CIRC") | str("NBS CRPL") | str("NBS CS") |
          str("NBS CIS") | str("NBS HR") | str("NBS IRPL") | str("NBS IP") | str("NBS LC") | str("NBS PS") |
          str("NBS BH")
        ).as(:series)
      end

      # Simple series (no publisher prefix)
      rule(:simple_series) do
        (
          str("AMS") | str("VTS") | # NEW - Added for NIST AMS and VTS series
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
          str("raft") | # NEW: Exclude "draft" from number suffix matching
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
          # CHANGED: Capture volume and issue_number separately for proper semantics
          (str("v") >> digits.as(:volume_number) >> str("n") >> digits.as(:issue_number)) |
          # Regular number with supplement and revision suffix: "154supprev"
          (digits >> str("supprev")) |
          # Regular number with edition and revision year-only: "13e2rev1908"
          (digits >> str("e") >> digits >> str("rev") >> digits) |
          # Regular number with edition, revision, and month-date: "13e2revJune1908"
          (digits >> str("e") >> digits >> str("rev") >> month_abbrev >> digits) |
          # Regular number with eN suffix and optional supplement (e.g., "101e2supp") - most specific
          (digits >> str("e") >> digits >> str("supp") >> digits.maybe) |
          # Edition prefix with revision and date: e2revJune1908
          (str("e") >> digits >> str("rev") >> month_abbrev >> digits) |
          # Edition prefix followed by digits and optional supplement with digits
          (str("e") >> digits >> str("supp") >> digits.maybe) |
          # Regular number with eN suffix (e.g., "101e2")
          (digits >> str("e") >> digits) |
          # NEW: Bare edition (just "e2" without number prefix)
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
        # Explicitly exclude month abbreviations at start (so -Feb1985 goes to edition, not second_number)
        month_abbrev.absent? >>
          # NEW: Exclude "draft" keyword
          str("draft").absent? >>
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
            # Lowercase letter suffix (e.g., "a", "b") - Session 219
            lower_letter.repeat(1, 2) |
            # Regular number with optional suffix - but NOT if part of FIPS date (digit-dash-month-digit-slash)
            (digits_with_suffix >> (dash >> month_abbrev >> digits >> slash).absent?)
          ).as(:second_number)
      end

      # Edition component per NIST spec: <edition-type><edition-id>
      # Type: "e" (edition), "r" (revision), "-" (historical)
      # ID: number (1-9) or year (yyyy)
      # Examples: e2, e2021, r5, -3
      rule(:edition) do
        (
          # Edition with "e" prefix: e2, e3, e2021 (1-4 digits for ID)
          (str("e") >> digits.as(:edition_id)).as(:edition_e) |
          # Revision with "r" prefix: r1, r5, r2021
          (str("r") >> digits.as(:edition_id)).as(:edition_r) |
          # Historical with "-" prefix: -2, -3 (ONLY if followed by non-digit or end)
          # This avoids consuming date patterns like "-1908"
          # Historical precedent uses small numbers (1-9), dates use 4-digit years
          (dash >> match("[1-9]").as(:edition_id) >> digit.absent?).as(:edition_historical)
        )
      end

      # Date component per NIST spec: -{YYYY} or -{YYYYMM} or -{YYYYMMDD}
      # Separate from Edition - both can coexist
      # Examples: -1908, -190806, -19770930
      rule(:date) do
        (
          # Date with month and day: -19770930 (YYYYMMDD)
          (dash >> match("[0-9]").repeat(4, 4).as(:date_year) >>
           match("[0-9]").repeat(2, 2).as(:date_month) >>
           match("[0-9]").repeat(2, 2).as(:date_day)) |
          # Date with month: -190806 (YYYYMM)
          (dash >> match("[0-9]").repeat(4, 4).as(:date_year) >>
           match("[0-9]").repeat(2, 2).as(:date_month)) |
          # Date with year only: -1908 (YYYY)
          (dash >> match("[0-9]").repeat(4, 4).as(:date_year)) |
          # Legacy month format: -June1908, -Jan1925 (normalize to YYYYMM)
          (dash >> month_abbrev.as(:date_month) >> digits.as(:date_year))
        ).as(:date)
      end

      # LEGACY EDITION PATTERNS (for backward compatibility during migration)
      # These will be gradually replaced as we migrate to proper Edition/Date components
      rule(:legacy_edition) do
        (
          # Complex revision patterns: r1a, r2b
          ((str("r") | str(" R")) >> match("[0-9]").repeat(1,
                                                           2).as(:edition) >> lower_letter.as(:edition_letter)) |
          # Edition with revision and year: rev2013, rev2020
          (str("rev") >> digits.as(:edition_year)) |
          # Edition with revision and date: e2revJune1908 (will migrate to e2 + date)
          ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >>
           str("rev") >> match("[A-Za-z]").repeat(3,
                                                  9).as(:edition_month) >> digits.as(:edition_year)) |
          # Edition with year and month: e201801 (ambiguous - could be e2018 or year 2018 month 01)
          (str("e") >> match("[0-9]").repeat(4,
                                             4).as(:edition_year) >> match("[0-9]").repeat(
                                               2, 2
                                             ).as(:edition_month).maybe) |
          # Revision-based edition: revJune1908, revJan1925 (normalize to date)
          (str("rev") >> match("[A-Za-z]").repeat(3,
                                                  9).as(:edition_month) >> digits.as(:edition_year))
        )
      end

      # CRPL range pattern (e.g., 1-2_3-1, 1-2_3-1A with suffix) - matches after first dash
      rule(:crpl_range) do
        (digits >> str("_") >> digits >> dash >> digits >> upper_letter.maybe).as(:crpl_range)
      end

      # Full report number - support dot-separated parts AND CRPL ranges
      # ENHANCED: Support multiple dashes for GCR patterns (Session 220)
      rule(:report_number) do
        first_number >>
          (
            # Multiple dash pattern for GCR: 21-917-48 (year-seq-part)
            (dash >> second_number >> dash >> digits) |
            # Dot-separated part (e.g., 984.4 = number 984, part 4)
            (dot >> second_number) |
            # Dash-separated (traditional)
            (dash >> (crpl_range | second_number))
          ).maybe
      end

      # Volume
      rule(:volume) do
        (space.maybe >> (str("v") | str(" Vol. "))) >>
          (digits >>
           # Support letter ranges (lowercase normalized in preprocessing)
           (str("a-l") | str("m-z") | str("A-L") | str("M-Z")).maybe >>
           # Support single uppercase letters (e.g., v3B, v1A)
           upper_letter.repeat(0, 2)).as(:volume)
      end

      # Part - enhanced to support patterns like p1adde1 AND pt3r1 (part with revision)
      rule(:part) do
        (space.maybe >> (str("pt") | str("p") | str("P")) | str(" Part ")) >>
          (digits >>
           # NEW: Revision after part number: pt3r1, p1r1 (space.maybe for preprocessing)
           (space.maybe >> str("r") >> digits).maybe >>
           # Existing: Addendum with optional edition: add, adde1
           (str("add") >> (str("e") >> digits).maybe).maybe >>
           (dash >> digits).maybe).as(:part)
      end

      # Revision
      rule(:revision) do
        (
          # NEW: Revision with month and year: rJun1992, r Jun1992 - LONGEST MATCH FIRST
          # Enhanced to support leading space (Session 219)
          (space.maybe >> (str("r") | str("rev")) >> space.maybe >> month_abbrev.as(:revision_month) >> digits.as(:revision_year)) |
          # Revision with slash and year: r6/1925, r11/1924 (NEW for LCIRC patterns)
          (space.maybe >> (str("r") | str("rev")) >> digits.as(:revision) >>
           slash >> digits.as(:revision_year)) |
          # Revision with 4-digit year directly: r1995, r 1995 (allow space before year)
          ((str(" r") | str("r")) >> space.maybe >> match("[0-9]").repeat(4,
                                                                          4).as(:revision_year)) |
          # Revision with year: rev2013, rev 2013 (allow space before year)
          (str("rev") >> space.maybe >> digits.as(:revision_year)) |
          # Revision with digits AND/OR letters: r1a, r1A, ra, r1
          # Enhanced to accept letter-only revisions and space before r
          # ENHANCED: Accept BOTH lowercase and uppercase letters in suffix
          ((str(" rev ") | str("rev") | str(" r") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
            (digits >> match("[a-zA-Z]").maybe | match("[a-zA-Z]").repeat(1)).as(:revision)) |
          # NEW: Standalone 'r' - MUST BE LAST to avoid consuming from other patterns
          # Matches " r" at end of input (after preprocessing: "800-56a r", "800-27 r")
          (str(" r") >> any.absent?).as(:revision_standalone)
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
      # Examples: /Upd1-2015, /Upd3-202102, -upd, /upd (after preprocessing)
      # Update number is optional (e.g., "500-300-upd" has no number)
      rule(:update) do
        (str("/Upd") | space >> (str("/upd") | str("-upd"))) >>
          (
            digits.as(:update_number).maybe >>
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
        space.maybe >>
          (str("supp") | str("sup")) >>
          (
            # Supplement followed by revision: supprev
            str("rev").as(:supplement_with_rev) |
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

      # Draft stage - enhanced to support suffix pattern and number after draft
      # ENHANCED: Accept optional space before dash to match after report_number
      rule(:draft) do
        (space >> str("(Draft)") |
         space.maybe >> dash >> str("draft") >> (space >> digits | digits).maybe | # Match " -draft 2" OR "-draft2"
         pd_suffix).as(:draft)
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
          edition | date | legacy_edition | revision |
          version | # MOVED BEFORE volume - try dotted versions (v1.1) before simple volumes (v1)
          volume | part | update | addendum |
          supplement | errata | language_code
        )
      end

      # CIRC Supplement identifier - split into base + supplement
      # Examples:
      # - "NBS CIRC 101e2supp" → base="NBS CIRC 101e2", supplement
      # - "NBS CIRC 25supp-1924" → base="NBS CIRC 25", supplement_year="1924"
      # - "NBS CIRC 24suppJan1924" → base="NBS CIRC 24", supplement_edition="Jan1924"
      # - "NBS CIRC suppJun1925-Jun1926" → date range supplement (no base)
      rule(:circ_supplement_identifier) do
        (str("NBS CIRC") | str("NBS LCIRC")).as(:series) >> space >>
          (
            # Date range supplement (no base, no number)
            (str("supp") >> month_abbrev.as(:supp_month_start) >> digits.as(:supp_year_start) >>
             dash >> month_abbrev.as(:supp_month_end) >> digits.as(:supp_year_end)).as(:supplement_date_range) |
            # With base identifier + supplement
            (
              # Capture base portion (everything before "supp")
              (
                # Number with edition: "101e2"
                (digits >> str("e") >> digits) |
                # Just number: "25", "24"
                digits
              ).as(:base_portion) >>
              # Supplement marker with optional metadata
              str("supp") >>

                # Month and year: Jan1924
                (month_abbrev.as(:supplement_month) >> digits.as(:supplement_year)).as(:supplement_edition)

            )
          )
      end

      # Dot-separated machine-readable format: NIST.SP.800-116 or #NIST.2024-01-15.123
      # Enhanced to support parts after number like NIST.SP.1011-I-2.0
      rule(:mr_identifier) do
        hash_prefix.maybe >>
          publisher >> dot >>
          simple_series >> dot >>
          report_number >>
          # Edition with underscore separator (MR format: 1648_2009)
          (str("_") >> digits.as(:edition_year)).maybe >>
          (dot >> (digits | upper_letter)).repeat(0, 3) >> # Support additional dot-separated parts
          # Support letter suffix before update (e.g., 8286C-upd1) - Session 219
          upper_letter.maybe >>
          (dash >> str("upd") >> digits.maybe).maybe >>
          parts.repeat >> draft.maybe
      end

      # Main identifier structure
      # Try compound series first (longest match), then publisher + simple series
      rule(:identifier) do
        circ_supplement_identifier |
          mr_identifier |
          (
            # Compound series (includes publisher in series name)
            compound_series >> (space | dot) >>
            old_stage.maybe >> # Old style stage after series
            report_number.maybe >> fips_date.maybe >> parts.repeat >> draft.maybe >> translation.maybe >> new_stage.maybe
          ) |
          (
            # Publisher + simple series - require space/dot between publisher and series
            publisher >> (space | dot) >>
            simple_series >>
            old_stage.maybe >> # Old style stage after series
            (space | dot) >>
            report_number.maybe >> fips_date.maybe >> parts.repeat >> draft.maybe >> translation.maybe >> new_stage.maybe
          ) |
          (
            # Simple series only (no publisher)
            simple_series >>
            old_stage.maybe >> # Old style stage after series
            (space | dot) >>
            report_number.maybe >> fips_date.maybe >> parts.repeat >> draft.maybe >> translation.maybe >> new_stage.maybe
          )
      end

      # CIRC Supplement identifier - split into base + supplement
      # Must be complete rule with all patterns
      rule(:circ_supplement_identifier) do
        (str("NBS CIRC") | str("NBS LCIRC")).as(:series) >> space >>
          (
            # Date range supplement (no base number)
            (str("supp") >> month_abbrev.as(:supp_month_start) >> digits.as(:supp_year_start) >>
             dash >> month_abbrev.as(:supp_month_end) >> digits.as(:supp_year_end)).as(:supplement_date_range) |
            # With base identifier + supplement
            (
              # Capture base portion (everything before "supp")
              (digits >> str("e") >> digits | digits).as(:base_portion) >>
              # Supplement marker
              str("supp") >>
              # Optional supplement metadata
              (
                (month_abbrev >> digits).as(:supplement_month_year) |
                (dash >> digits.as(:supplement_year)) |
                str("").as(:supplement_empty)
              )
            )
          )
      end

      root(:identifier)
    end
  end
end
