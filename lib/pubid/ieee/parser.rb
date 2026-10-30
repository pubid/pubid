# frozen_string_literal: true

module Pubid
  module Ieee
    # Parser class for IEEE identifiers
    # Single Responsibility: Parsing IEEE identifier syntax
    # Note: IEEE is extremely complex with many edge cases
    class Parser
      def self.normalize_input(string)
        # Strip .pdf extension if present (Pattern 3: File Extensions)
        cleaned = string.sub(/\.pdf$/i, "")

        # Note: IEC and ANSI identifiers are NOT filtered here because they can have
        # IEEE co-publication or adoption. The Base.parse method handles determining
        # which standards are actually IEEE-related.
        # ISO-only standards are still filtered as they have separate handling.

        # NEW: Normalize multiple spaces to single space
        # No valid IEEE identifier pattern needs more than 1 space
        cleaned = cleaned.gsub(/\s+/, " ")

        # NEW Session 171: Remove wrong ! prefix
        cleaned = cleaned.gsub(/^!IEEE /, "IEEE ")

        # NEW Phase 1: Handle HTML entities comprehensively
        cleaned = cleaned.gsub("&#x2122;", "™") # Trademark symbol
        cleaned = cleaned.gsub("&#x2019;", "'") # Smart apostrophe
        cleaned = cleaned.gsub("&amp;amp;", "&")   # Double-encoded ampersand
        cleaned = cleaned.gsub("&amp;", "&")       # Single-encoded ampersand

        # The joint IEEE/CSA catalogue spells the type word before the
        # project number ("IEEE/CSA Draft P844.1/D2, Sept, 2016"): the P
        # already carries the project semantics (docs/IEEE-DRAFT-STAGES.md
        # §1.1), so the redundant word drops and the joint route parses.
        cleaned = cleaned.gsub(%r{IEEE/CSA Draft (P[A-Z0-9])}, 'IEEE/CSA \1')
        # The same redundant word rides the wider joint lists
        # ("IEEE//ISO/IEC Draft P29119-2/D=DIS-201112"); the crawl also
        # doubles the publisher slash (the 2026-10-14 ruling: the list
        # normalizes to single slashes). Drop the word and collapse the
        # slash before the joint route sees either.
        # Scoped to the D= stage-draft tail: the doubled-D ("DDIS2") and
        # stage-month ("DFDIS_March") tails route elsewhere until the
        # grammar carries them - dropping the word there would route
        # them to the generic standard face with a slashed copublisher.
        cleaned = cleaned.gsub(%r{((?:IEEE|ISO|IEC)(?:/(?:IEEE|ISO|IEC|CSA))+)\s+Draft\s+(P[A-Z0-9][A-Z0-9.-]*/D=[A-Z])}, '\1 \2')
        cleaned = cleaned.gsub(%r{(IEEE|ISO|IEC)//}, '\1/')
        # The three-way ISO-led list glues the language marker to the
        # year ("ISO/IEC/IEEE 8802-1AC-2018(E)"): the spaced spelling is
        # read as the language marker and dropped, the glued one falls
        # into parenthetical content and prints. Re-spell the boundary.
        # Scoped to the three-way lists: the two-way IEC/IEEE copublished
        # form keeps its glued (E) as identity ("…:2012(E)").
        cleaned = cleaned.gsub(
          %r{\A((?:ISO/IEC/IEEE|IEEE/ISO/IEC|IEEE/IEC/ISO)\s+[^()]+?[^()\s])\(E\)\z},
          '\1 (E)',
        )
        # The stage-first joint draft's dash part carries a bare comma
        # year ("IEC/IEEE FDIS P60780-323, 2015"): the joint route takes
        # no bare year there and the copublished route claims the string,
        # so drop the non-identity year and let the stage-first route
        # read the dash part (the rendered face is the dot human).
        cleaned = cleaned.gsub(
          %r{\A((?:IEC/IEEE|IEEE/IEC)\s+(?:FDIS|FCD|CDV|DIS|CD|WD|PWI|NP)\s+P\d+(?:-\d+)+),\s+\d{4}\z},
          '\1',
        )
        # A two-digit draft designator spelled without its D
        # ("IEEE P1052/08, September 2018"): the corpus face is the D
        # ordinal ("…/D08").
        cleaned = cleaned.gsub(
          %r{\AIEEE\s+(P[\d.-]+)/(\d{2}),\s+([A-Za-z]+)\s+(\d{4})\z},
          'IEEE \1/D\2, \3 \4',
        )
        # The revision word rides after the draft ordinal
        # ("IEEE PC37.30.2/D03 Rev 8, October 2013"): move it onto the
        # number and mark the document as the draft it spells.
        cleaned = cleaned.gsub(
          %r{\AIEEE\s+((?:P)?C?[\d.]+)/D(\d+)\s+Rev\s+(\d+),\s+([A-Za-z]+)\s+(\d{4})\z},
          'IEEE Draft \1Rev\3/D\2, \4 \5',
        )
        # The IEEE-led joint list's dash/underscore stage tail carries a
        # month-name date ("IEEE/ISO/IEC P29119-2-DIS, December 2011",
        # "IEEE/ISO/IEC P29119-4_FDIS, December 2020"). The generic route
        # claims it first and answers with a slashed copublisher
        # ("IEEE//ISO/IEC Draft …"), so re-spell the stage as the D=
        # designator the joint route reads. Scoped to the IEEE-led list:
        # the ISO/IEC- and IEC/IEEE-led forms already render the face.
        cleaned = cleaned.gsub(
          %r{\A(IEEE(?:/(?:IEEE|ISO|IEC)){2,})\s+(P[A-Z0-9][A-Z0-9.-]*?)[-_](FDIS|FCD|CDV|DIS|CD|WD|PWI|NP)(\d*),\s+([A-Za-z]+)\s+(\d{4})\z}
        ) do
          month = ::Pubid::Ieee::Builder::REV_MONTH_NUMBERS[
            Regexp.last_match(5).capitalize
          ]
          if month
            "#{Regexp.last_match(1)} #{Regexp.last_match(2)}/" \
              "D=#{Regexp.last_match(3)}#{Regexp.last_match(4)}-" \
              "#{Regexp.last_match(6)}#{month}"
          else
            Regexp.last_match(0)
          end
        end
        # The crawl glues the month onto the stage after the code's slash
        # ("IEEE/IEC/ISO P80005-1/FDIS_March 2012", and its canonical
        # comma form "… Draft P80005-1/FDIS_March, 2012"): the stage is
        # the ISO/IEC token and the month belongs to the date (the
        # 2026-10-25 ruling) — decode onto the D= designator face. Scoped
        # to a real month name glued to a stage token; stage iteration
        # ("_CDV/V3", "_CDV July 2015") has its own routes.
        cleaned = cleaned.gsub(
          %r{\A((?:IEEE|ISO|IEC)(?:/(?:IEEE|ISO|IEC))*\s+(?:Draft\s+)?P?[A-Z0-9][A-Z0-9.-]*/)(FDIS|FCD|CDV|DIS|CD|WD|PWI|NP)_([A-Za-z]+),?\s+(\d{4})\z}
        ) do
          month = ::Pubid::Ieee::Builder::REV_MONTH_NUMBERS[
            Regexp.last_match(3).capitalize
          ]
          if month
            "#{Regexp.last_match(1)}D=#{Regexp.last_match(2)}-" \
              "#{Regexp.last_match(4)}#{month}"
          else
            Regexp.last_match(0)
          end
        end
        # The lettered REV spellings glue to the number ("P1310Rev3",
        # "P1722Rev1") or carry an after-word separator ("REV.ma",
        # "REV-ma"); the rev rules read a space or a bare word
        # respectively, so the boundary normalizes (the render keeps the
        # glued face - "IEEE P1310 Rev3/D2-2011-02" parses to
        # "IEEE P1310Rev3/D2-2011-02"). The before-word separator the
        # Rev doctrine carries ("-REVmc") is untouched.
        cleaned = cleaned.gsub(%r{(REV|Rev|rev)[.\-](?=[A-Za-z])}, '\1')
        cleaned = cleaned.gsub(%r{(\d)(REV|Rev|rev)}, '\1 \2')

        # The corrigendum's own draft follows the ordinal after a comma
        # ("P11073-10418-2011/Cor 1, D4, July 2015"): re-spell the comma as
        # the draft separator so the cor route's draft slot reaches it.
        cleaned = cleaned.gsub(%r{/Cor(?:rigendum)? (\d+), (D[A-Z0-9])}, '/Cor \1/\2')

        # The corrigendum's own draft rides before the ordinal in the
        # house order ("PC37.101-2006/D2, 2007/Cor. 1"): the catalogue
        # spellings "…/Cor 1, D4, July 2015" and "…/Cor 1-201x/D5,
        # April 2012" re-order into it, with the draft's date glued
        # -YYYY-MM (pubid ruling 2026-10-14: no comma dates).
        cleaned = cleaned.gsub(
          %r{/Cor(?:rigendum)? (\d+(?:-[0-9xX]{4})?)/(D[A-Z0-9][^,]*), ([A-Za-z]+) (\d{4})}
        ) do
          month = ::Pubid::Ieee::Builder::REV_MONTH_NUMBERS[Regexp.last_match(3).capitalize]
          if month
            "/#{Regexp.last_match(2)}-#{Regexp.last_match(4)}-#{month}/Cor. #{Regexp.last_match(1)}"
          else
            Regexp.last_match(0)
          end
        end
        cleaned = cleaned.gsub(
          %r{/Cor(?:rigendum)? (\d+), (D[A-Z0-9][^,]*), ([A-Za-z]+) (\d{4})}
        ) do
          month = ::Pubid::Ieee::Builder::REV_MONTH_NUMBERS[Regexp.last_match(3).capitalize]
          if month
            "/#{Regexp.last_match(2)}-#{Regexp.last_match(4)}-#{month}/Cor. #{Regexp.last_match(1)}"
          else
            Regexp.last_match(0)
          end
        end

        # NEW Phase 1: Fix number spacing issues (e.g., "C57.1 2.25" → "C57.12.25")
        # This handles cases where a space appears in the middle of a number
        cleaned = cleaned.gsub(/(\d+\.\d+)\s+(\d+\.)/, '\1\2')

        # NEW Phase 1: Fix year spacing issues (e.g., "1 996" → "1996")
        # Remove spaces within 4-digit years
        cleaned = cleaned.gsub(/\b(1|2)\s+(\d{3})\b/, '\1\2')

        # NEW: Convert IEC/IEEE space-separated to semicolon format
        # Pattern: "IEC 61523-3 First edition 2004-09; IEEE 1497" → already semicolon
        # Pattern: "IEC 62539 First Edition 2007-07 IEEE 930" → needs semicolon
        # Pattern: "IEC 60076-21:2011 Edition 1.0 2011-12 IEEE Std C57.15" → needs semicolon (issue #202)
        # Match: IEC identifier (with optional colon-year, optional "First"/numeric
        # Edition + YYYY-MM) + space + IEEE identifier.
        cleaned = cleaned.gsub(
          /(IEC\s+\d+(?:-\d+)?(?::\d{4})?(?:\s+(?:First\s+)?[Ee]dition\s+\d+(?:\.\d+)?\s+\d{4}-\d{2})?)\s+(IEEE\s+Std\s+\S+|IEEE\s+\S+)/,
          '\1; \2'
        )

        # Strip ":YYYY" from IEC numbers when an Edition clause follows — the
        # IEEE parser's number rule doesn't accept the colon-year form, but
        # the year is preserved in the "Edition N.M YYYY-MM" suffix.
        # (issue #202)
        cleaned = cleaned.gsub(
          /^(IEC\s+\d+(?:-\d+)?):\d{4}(\s+(?:First\s+)?[Ee]dition\s+\d+(?:\.\d+)?\s+\d{4}-\d{2})/,
          '\1\2'
        )

        # NEW Phase 1 (Session 141): Remove literal trademark symbol
        # "C57.110™-2018" → "C57.110-2018"
        cleaned = cleaned.gsub(/™/, "")

        # NEW Phase 1 (Session 141): Fix specific year typo
        # "19969" → "1969" (very specific pattern, won't affect other text)
        cleaned = cleaned.gsub(/\b19969\b/, "1969")

        # NEW Session 169: Fix comma typo in 802.3 series numbers
        # "802.3ch-2020,802.3ca-2020" → "802.3ch-2020, 802.3ca-2020"
        # Very specific: 4 digits, comma, 3 digits (likely 802.3xx typo)
        cleaned = cleaned.gsub(/(\d{4}),(\d{3})/, '\1, \2')

        # NEW Session 169: Fix /lNT typo (lowercase L as 1)
        # "1003.1/2003.l/lNT" → "1003.1/2003.1/INT"
        cleaned = cleaned.gsub(/\/lNT\b/, "/INT")
        cleaned = cleaned.gsub(".l/", ".1/") # Also fix .l/ -> .1/

        # NEW Session 169: Fix I99O typo (letter I and O instead of digits)
        # "IEEE 1076-CONC-I99O" → "IEEE 1076-CONC-1990"
        cleaned = cleaned.gsub(/\bI99O\b/, "1990")

        # NEW: Fix common typos (Category 9)
        cleaned = cleaned.gsub(/^EEE /, "IEEE ")

        # NEW Session 170: Additional safe typo fixes
        # Fix "I EEE" (space between I and EEE)
        cleaned = cleaned.gsub(/^I EEE /, "IEEE ")

        # Fix "lEEE" (lowercase L instead of I)
        cleaned = cleaned.gsub(/^lEEE /, "IEEE ")

        # Fix missing closing parenthesis at end only (very conservative)
        # Only if there's exactly one more opening than closing paren
        open_count = cleaned.count("(")
        close_count = cleaned.count(")")
        if open_count == close_count + 1 && !cleaned.end_with?(")")
          cleaned = "#{cleaned})"
        end

        # NEW Phase 1: Remove trailing commas/colons and text
        cleaned = cleaned.gsub(/,\s*Standard\s*$/, "") # ", Standard" at end
        cleaned = cleaned.gsub(/[,:]\s*$/, "") # Trailing comma/colon
        cleaned = cleaned.gsub(/,\s+and\s+IEEE\s+Std\s/, " and ") # Handle "IEEE Std and Std" case

        # Enhanced: Fix unbalanced parentheses comprehensively
        # Handle three cases: missing closing, extra opening, nested unbalanced
        open_count = cleaned.count("(")
        close_count = cleaned.count(")")

        if open_count > close_count
          # More opening than closing - add closing parens at end
          # This handles both simple missing and nested unbalanced cases
          missing = open_count - close_count
          cleaned = cleaned + (")" * missing)
        elsif close_count > open_count
          # More closing than opening - remove extra closing from end
          # Very conservative: only remove trailing excess closing parens
          extra = close_count - open_count
          cleaned = cleaned.sub(/\){#{extra}}$/, "")
        end

        # === SESSION 173: TODO.IEEE-MUST-DO.txt Preprocessing Enhancements ===

        # Part A: Simple Normalizations (Lines 13, 16, 32-35, 36, 39-41 from TODO)

        # 1. Missing dash before year: "802.16g 2007" → "802.16g-2007"
        # But be careful not to affect month names (already have space)
        # Only apply if: digit + space + 4-digit year (and not after a month name)
        cleaned = cleaned.gsub(/(\d)\s+(\d{4})(?=\s*\(|\s*$)/, '\1-\2')

        # 2. Space-dash-space before year: "802.1ag - 2007" → "802.1ag-2007"
        # This is distinct from " - " in titles, targets space-dash-space-year pattern
        cleaned = cleaned.gsub(/\s+-\s+(\d{4})\b/, '-\1')

        # 3. Add missing "Std" after IEEE: "IEEE 1070-1995" → "IEEE Std 1070-1995"
        # Only at start of string, IEEE + space + digit
        cleaned = cleaned.gsub(/^IEEE\s+(?!Std\b)(\d)/, 'IEEE Std \1')

        # 3.5. Convert "IEEE No." to "IEEE Std": "IEEE No. 264-1968" → "IEEE Std 264-1968"
        # NOTE: Do NOT convert AIEE No - AIEE uses "No" as standard format
        cleaned = cleaned.gsub(/^IEEE\s+No\.\s*/, "IEEE Std ")
        cleaned = cleaned.gsub(/^IEEE\s+No\s/, "IEEE Std ")
        # Skip AIEE No conversion - AIEE preserves "No" format

        # 4. Space before slash in dual published: "262-1973 /ANSI" → "262-1973/ANSI"
        cleaned = cleaned.gsub(/\s+\//, "/")

        # 5. Comma before Edition: ", 1998 Edition" → "-1998"
        # Normalize to standard year format for parser
        cleaned = cleaned.gsub(/,\s+(\d{4})\s+Edition/, '-\1')

        # 6. ISO/IEC spacing: "ISO/IEC15802" → "ISO/IEC 15802"
        # Add space between publisher prefix and number
        cleaned = cleaned.gsub(/(ISO\/IEC)(\d)/, '\1 \2')

        # Part B: Publisher Order (Line 38 from TODO)

        # Fix wrong publisher order: "IEEE Std ANSI/IEEE" → "ANSI/IEEE Std"
        # This handles cases where IEEE Std appears before ANSI/IEEE publisher
        cleaned = cleaned.gsub(/^IEEE\s+Std\s+(ANSI\/IEEE)/, '\1 Std')

        # Part C: Dual Published Formats (Lines 8, 19 from TODO)

        # 1. Semicolon to parenthetical for dual published (MultiLabeledIdentifier)
        # "IEEE Std 120-1955; ASME PTC 19.6-1955" → "IEEE Std 120-1955 (ASME PTC 19.6-1955)"
        # Only if semicolon + space + organization abbreviation (capital letters)
        if cleaned.match?(/;\s+[A-Z]{2,}/)
          cleaned = cleaned.sub(/;\s+([A-Z][^;]+)$/, ' (\1)')
        end

        # === SESSION 174: Additional TODO.IEEE-MUST-DO.txt Preprocessing ===

        # Part A: Edition Abbreviation Normalization (Lines 10-11)
        # Pattern: ", 1999 Edn. (Reaff 2003)" → "-1999 (R2003)"
        # Normalize both the Edition abbreviation and the Reaffirmed format
        cleaned = cleaned.gsub(/,\s+(\d{4})\s+Edn\.\s+\(Reaff\s+(\d{4})\)/,
                               '-\1 (R\2)')
        # Also handle without initial comma (might occur in relationships)
        cleaned = cleaned.gsub(/(\d{4})\s+Edn\.\s+\(Reaff\s+(\d{4})\)/,
                               '\1 (R\2)')

        # Part B: IRE Parenthetical Split (Line 9)
        # Pattern: "(Reaffirmed 1980, 56 IRE 28.S2)" → "(R1980) (56 IRE 28.S2)"
        # Split nested reaffirmation + IRE reference into two parentheticals
        cleaned = cleaned.gsub(/\(Reaffirmed\s+(\d{4}),\s+(\d+\s+IRE[^)]+)\)/,
                               '(R\1) (\2)')

        # Part C: Slash to Parenthetical (Line 37)
        # Pattern: "number-year/ANSI identifier" → "number-year (ANSI identifier)"
        # Only convert if slash is followed by ANSI and NOT a relationship keyword
        # Look ahead to ensure we're at end of main identifier (before paren or end of string)
        cleaned = cleaned.gsub(%r{(\d{4})/ANSI\s+([^(]+)(?=\s*\(|$)},
                               '\1 (ANSI \2)')

        # Part D: ISO/IEC TR Spacing (Line 40)
        # Pattern: "ISO/IEC TR11802" → "ISO/IEC TR 11802"
        # Add space after TR when directly followed by digit
        cleaned = cleaned.gsub(/(ISO\/IEC\s+TR)(\d)/, '\1 \2')
        # === SESSION 178: AIEE Dual Numbers Expansion (Line 45) ===

        # Part E: AIEE "Nos X and Y" Expansion
        # Pattern: "AIEE Nos 72 and 73 - 1932" → "AIEE No 72-1932 and AIEE No 73-1932"
        # Expands dual AIEE numbers to separate identifiers with shared year
        if cleaned.match?(/AIEE\s+Nos\s+(\d+)\s+and\s+(\d+)\s+-\s+(\d{4})/)
          cleaned = cleaned.sub(/AIEE\s+Nos\s+(\d+)\s+and\s+(\d+)\s+-\s+(\d{4})/) do
            first_num = $1
            second_num = $2
            year = $3
            "AIEE No #{first_num}-#{year} and AIEE No #{second_num}-#{year}"
          end
        end

        # === SESSION 222: TODO.IEEE-MUST-FIX-IDs.txt Comprehensive Fixes ===

        # Part A: Typo Fixes
        # 1. "Stad" -> "Std" (typo)
        cleaned = cleaned.gsub(/\bStad\b/, "Std")

        # 2. Lowercase "std" -> "Std" when after IEEE/ANSI publishers
        cleaned = cleaned.gsub(/\b(IEEE|ANSI|AIEE)\s+std\b/, '\1 Std')

        # Part B: Symbol Normalization
        # 3. Additional (TM) patterns - strip them out
        cleaned = cleaned.gsub("(TM)", "")

        # Part C: Year-first format normalization
        # 4. Pattern "62704-4/D4, 2020" -> "IEEE P62704-4/D4, 2020"
        # Only if starts with digits-dash-digits/D pattern
        if cleaned.match?(/^(\d+[-.]\d+)\/D\d+/)
          cleaned = "IEEE P#{cleaned}"
        end

        # Part E: Relationship Text Normalization
        # 6. "Proposed Revision of" -> "Revision of"
        cleaned = cleaned.gsub("Proposed Revision of", "Revision of")

        # 7. "ammended" typo -> "amended"
        cleaned = cleaned.gsub(/\bammended\b/i, "amended")

        # Part F: Trailing Characters After Special Patterns
        # 8. Remove trailing periods after /INT, /Cor, etc.
        cleaned = cleaned.gsub(/(\/INT|\/Cor\s+\d+-\d{4})\./, '\1')

        # Part G: Conformance Pattern Spacing
        # 9. Fix spacing in "/Conformance" patterns WITHOUT year (malformed only)
        # "1904.1(TM)/Conformance02" -> "1904.1 /Conformance02" (space before slash)
        # BUT: DO NOT touch valid patterns like "802.16/Conformance01-2003" (with year)
        # Use positive check for year suffix to exclude valid patterns
        # Actually, this preprocessing is breaking valid patterns - just remove it entirely
        # The parser can handle both "6/Conformance01-2003" and "6 /Conformance02" formats

        # Part H: Edition Text After /INT
        # 10. Handle ", Month YYYY Edition" after /INT by converting to month-year format
        # "1003.1/INT, March 1994 Edition" -> "1003.1/INT, March 1994"
        cleaned = cleaned.gsub(/(\/INT),\s+([A-Z][a-z]+)\s+(\d{4})\s+Edition/,
                               '\1, \2 \3')

        # Part I: Handle "Ed." abbreviation
        # 11. "Dec. 1994 Ed." -> "Dec. 1994"
        cleaned = cleaned.gsub(/\s+Ed\.\s*$/, "")

        # === PHASE 2: High-impact preprocessing for fixture failures ===

        # Quick wins from SESSION 224 (must come before more complex fixes)

        # Remove period after "Std": "IEEE Std." -> "IEEE Std"
        cleaned = cleaned.gsub(/\bStd\.\s+/, "Std ")

        # Title portion removal after year: "YYYY - IEEE Standard for..."
        cleaned = cleaned.gsub(
          /(\d{4})(\s+\([^)]+\))?\s+-\s+IEEE\s+Standard\s+for.*$/, '\1\2'
        )

        # Fix 2A: "IEEE PC" prefix -> "IEEE Std PC" or "IEEE P" treatment
        # "IEEE PC37.20.9/D7.3A" -> needs to parse as IEEE project draft
        # Strategy: Add "Std" after "IEEE" when followed by "PC" to route to standard pattern
        # Actually, the issue is the number rule consumes "PC37" as P + C37.
        # Better: normalize "IEEE PC" to "IEEE Std PC" so it hits the standard identifier path
        cleaned = cleaned.gsub(/^IEEE\s+PC(\d)/, 'IEEE Std PC\1')
        cleaned = cleaned.gsub(/^IEEE\s+Unapproved\s+Draft\s+Std\s+PC(\d)/,
                               'IEEE Unapproved Draft Std PC\1')

        # Fix 2B: "IEEE P" without "Std"/"Draft" prefix
        # ieee_p_identifier rule handles these directly - no preprocessing needed
        # Only handle "IEEE P" followed by "and ASHRAE" (copub case)
        cleaned = cleaned.gsub(/^IEEE\s+P(\d+)\s+and\s+ASHRAE/,
                               'IEEE Std P\1 and ASHRAE')

        # Fix 2C: "ISO/IEC XXXX-YYYY: Title" -> strip title after colon for ISO/IEC published standards
        # These are ISO-format identifiers with IEEE adoption, strip the title
        cleaned = cleaned.gsub(/^(ISO\/IEC \d+[-.]\d+-\d{4}):.*$/, '\1')
        cleaned = cleaned.gsub(/^(ISO\/IEC \d+-\d{4}):.*$/, '\1')

        # Fix 2D: "ISO/IEC XXXX : YYYY" -> normalize spacing around colon
        cleaned = cleaned.gsub(/^(ISO\/IEC \d+[-.]\d*)\s*:\s*(\d{4})/, '\1:\2')
        cleaned = cleaned.gsub(/^(ISO\/IEC \d+)\s*:\s*(\d{4})/, '\1:\2')

        # Fix 2G: "IEC/IEEE PXXX_D5" -> underscore to slash
        cleaned = cleaned.gsub(/^(IEC\/IEEE P[\w.-]+)_D/, '\1/D')

        # Fix 2H: "IEC XXXX First edition YYYY-MM; IEEE NNNN" -> normalize semicolon
        # Already handled by earlier semicolon normalization

        # (Fix 2I removed: "IEEE/ISO/IEC PXXX/…" is no longer rewritten to
        # ISO-first — the printed publisher order is the organization's
        # perspective (pubid#469) and the joint P-form rule parses it as
        # printed.)

        # Fix 2J: "IEEE/IEC PXXX D5" -> normalize space to slash before D
        cleaned = cleaned.gsub(/^(IEEE\/IEC P[\w.-]+)\s+D(\d)/, '\1/D\2')
        cleaned = cleaned.gsub(
          /^(IEEE\/IEC P[\w.-]+)\s+(CDV|FDIS|CD|DIS|ED\d)/, '\1/\2'
        )

        # Fix 2K: "ISO /IEC/IEEE" -> fix space before slash
        cleaned = cleaned.gsub(/^ISO\s+\/IEC\/IEEE/, "ISO/IEC/IEEE")
        cleaned = cleaned.gsub(/^ISO\s+\/IEC/, "ISO/IEC")

        # Fix 2L: "IS0" typo (letter O instead of digit 0)
        cleaned = cleaned.gsub(/^IS0\//, "ISO/")

        # Fix 2M: "IEEE-P15026-3-DIS-January 2015" -> dash-separated format
        # Normalize to "ISO/IEC/IEEE P15026-3/DIS, January 2015"
        cleaned = cleaned.gsub(/^IEEE-P(\d+)-(\d+)-DIS-(.*)/,
                               'ISO/IEC/IEEE P\1-\2/DIS, \3')

        # Fix 2N: "IEEE/CSA P844.1/293.1/D2" -> normalize CSA dual numbering
        cleaned = cleaned.gsub(/^IEEE\/CSA\s+(P[\d.]+)\/([\d.]+)\/D(\d+)/,
                               'IEEE/CSA \1/D\3')

        # Fix 2O: "IEEE Approved Draft Std P" -> normalize spacing
        cleaned = cleaned.gsub(/^IEEE\s+Approved\s+Draft\s+Std\s+(P\d)/,
                               'IEEE Approved Draft Std \1')
        # Fix: "IEEE Approved Draft Std P1234 / D12" -> remove space before slash
        cleaned = cleaned.gsub(/^(IEEE Approved Draft Std P[\w.-]+)\s+\/\s*D/,
                               '\1/D')

        # Fix 2P: "IEEE/EIA" -> normalize (parser handles IEEE/EIA via copublisher)
        # Already works - no fix needed

        # Fix 2Q: AIEE format variations
        # "AIEE No.1C-1954" -> "AIEE No. 1C-1954" (add space after No.)
        cleaned = cleaned.gsub(/^AIEE\s+No\.\s*(\d)/, 'AIEE No. \1')
        # "AIEE no 700-1945" -> "AIEE No 700-1945" (capitalize)
        cleaned = cleaned.gsub(/^AIEE\s+no\s/, "AIEE No ")
        # "AIEE Std No. 800" -> "AIEE Standard No 800" (normalize type word)
        cleaned = cleaned.gsub(/^AIEE\s+Std\s+No\.\s*/, "AIEE Standard No ")
        # "AIEE No 750.1-1960" -> handled by AIEE parser if decimal support added

        # Fix 2R: "IEEE PSI 10/D2" -> normalize to "IEEE/ASTM PSI 10/D2"
        cleaned = cleaned.gsub(/^IEEE\s+PSI\s+(\d)/, 'IEEE/ASTM PSI \1')

        # Fix 2S: "IEEE/IEC P62271-111/PC37.60_D5" -> normalize
        cleaned = cleaned.gsub(/^(IEEE\/IEC P[\d.-]+\/PC[\d.]+)_D/, '\1/D')

        # Fix 2T: "IEC P62271-111/IEEE PC37.60_D5" -> normalize to IEC/IEEE format
        cleaned = cleaned.gsub(/^IEC\s+(P[\d.-]+)\/IEEE\s+(PC[\d.]+)_D/,
                               'IEC/IEEE \2/D')

        # Fix 2U: "IEC/IEC P" -> "IEC/IEEE P" (typo)
        cleaned = cleaned.gsub(/^IEC\/IEC\s+(P\d)/, 'IEC/IEEE \1')

        # Fix 2V: "NACE SPXXXX-YYYY/IEEE Std NNNN-YYYY" -> normalize slash to parenthetical
        cleaned = cleaned.gsub(/^(NACE\s+SP\d+-\d+)\/(IEEE\s+Std\s+\d+-\d+)$/,
                               '\1 (\2)')

        # Fix 2W: "IEEE Std 802.11g-2003 (Amendment to IEEE Std 802.11, 1999 Edn. (Reaff 2003) as amended by"
        # This is a complex relationship - strip the parenthetical if too complex
        # Let the parser handle it but fix "Edn." to "Edition"
        cleaned = cleaned.gsub("Edn.", "Edition")

        # Fix 2X: "IEEE-P15026-3-DIS" format -> normalize
        # Already handled by Fix 2M

        # Fix 2Y: "P1635/D10/ASHARE 21/D10" -> fix ASHARE typo to ASHRAE
        cleaned = cleaned.gsub("ASHARE", "ASHRAE")

        # Fix 2Z: "PC37.30.2/D043 Rev 18" -> normalize draft version with Rev
        # "PC57-15 D2.0" -> normalize to "P57-15/D2.0"
        cleaned = cleaned.gsub(/^PC(\d)/, 'P\1')

        # Fix 2AA: "IEEE/ISO/IEC 8802-1Q-2020/Amd31-2021" -> normalize
        cleaned = cleaned.gsub(/^IEEE\/ISO\/IEC\s+(8802[\w.-]+)/,
                               'ISO/IEC/IEEE \1')

        # Fix 2AB: "IEEE C57.139/D14June 2010" -> add missing space
        cleaned = cleaned.gsub(
          /^(IEEE\s+C?\d[\d.]*\/D\d+)([A-Z][a-z]+\s+\d{4})/, '\1, \2'
        )

        # Fix 2AC: "IEEE Std: Title" -> strip colon and title (ANSI/IEEE Std: )
        cleaned = cleaned.gsub(/^(ANSI\/IEEE Std):\s+.*$/, '\1')

        # Fix 2AD: "IEEE 1076 IEC 61691-1-1 First edition 2004-10" -> semicolon format
        cleaned = cleaned.gsub(
          /^(IEEE\s+[\d.]+)\s+(IEC\s+\d+[-\d]*\s+.*edition\s+\d{4}-\d{2})$/i, '\1; \2'
        )

        # Fix 2AE: "IEEE No 29-1941 / ASA C77.1-1943" -> normalize to IEEE Std format
        cleaned = cleaned.gsub(/^IEEE\s+No\s+(\d+-\d+)\s+\/\s+ASA\s+(.*)/,
                               'IEEE Std \1 (ASA \2)')

        # Fix 2AF: "IEEE Std 1003.1/2003.l/lNT" -> fix typos
        # .l -> .1 and lNT -> INT handled by existing fixes

        cleaned
      end
    end
  end
end
