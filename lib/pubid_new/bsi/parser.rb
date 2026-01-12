# frozen_string_literal: true

require "parslet"

module PubidNew
  module Bsi
    class Parser < Parslet::Parser
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:slash) { str("/") }
      rule(:plus) { str("+") }
      rule(:colon) { str(":") }

      # BSI publisher
      rule(:bs) { str("BS") | str("BSI") }

      # Specialized prefixes - Multi-letter BEFORE single-letter (longest match first)
      rule(:multi_letter_prefix) do
        # Flex type prefixes for supplement/addendum documents (5-character first)
        str("E9111") |
        # CECC (4-character)
        str("CECC") |
        # 4-character prefixes
        str("2HC") | str("2HR") | str("2SP") | str("2TA") |
        str("3HR") | str("3TA") |
        # 3-character prefixes
        str("2A") | str("2B") | str("2C") | str("2F") | str("2G") |
        str("2L") | str("2M") | str("2S") |
        str("3B") | str("3F") | str("3G") | str("3J") | str("3L") | str("3S") |
        str("4F") | str("4L") | str("4S") |
        str("5S") | str("7S") |
        # 2-character prefixes
        str("SP")
      end

      rule(:single_letter_prefix) do
        # Two-letter prefixes BEFORE single-letter
        str("AU") | str("HC") | str("MA") | str("PL") | str("QC") | str("TA") |
        # Single-letter prefixes
        str("A") | str("B") | str("C") | str("F") | str("G") |
        str("L") | str("M") | str("S") | str("X")
      end

      rule(:specialized_prefix) do
        (multi_letter_prefix | single_letter_prefix).as(:prefix)
      end

      # Flex documents (BSI Flex or just Flex) - BSI is already normalized to BS
      rule(:flex) { str("BSI Flex") | str("BS Flex") | str("Flex") }

      # Types for native BSI standards
      rule(:dd) { str("DD") }
      rule(:pd) { str("PD") }
      rule(:pas) { str("PAS") }
      rule(:na) { str("NA") }
      rule(:handbook) { str("Handbook") | str("HB") }
      rule(:pp) { str("PP") }
      rule(:bip) { str("BIP") }

      # Index suffix - handles three formats:
      # 1. Colon format: BS 5000:Index:1981
      # 2. Space format: BS 185 Index:1964
      # 3. Issue format: BS 5000 Index Issue 4:1980
      rule(:index_suffix) do
        # Issue format: " Index Issue N" (must be before colon format to match correctly)
        space >> str("Index") >> space >> str("Issue") >> space >> digits.as(:issue_number) |
        # Colon format: ":Index"
        colon.as(:colon_sep) >> str("Index") |
        # Space format: " Index"
        space >> str("Index")
      end

      # Stage prefixes
      rule(:draft) { str("Draft BS") | str("DBS") }

      # Adopted organizations - order matters!
      rule(:en) { str("EN") }
      rule(:iso) { str("ISO") }
      rule(:iec) { str("IEC") }
      rule(:cispr) { str("CISPR") }
      rule(:cen) { str("CEN") }
      rule(:clc) { str("CLC") }

      # National Annex prefix (special case: "NA to BS..." or "NA+A1:2012 to BS...")
      rule(:na_with_supplements) do
        str("NA") >> supplement.repeat(1).as(:na_supplements) >> space >> str("to ")
      end

      rule(:na_simple) do
        str("NA to ")
      end

      rule(:na_prefix) do
        (na_with_supplements | na_simple).as(:na_prefix)
      end

      # Publisher/Type - longer patterns first
      rule(:publisher_or_type) do
        na_prefix >>
        (draft.as(:stage) |
         dd.as(:type) |
         pd.as(:type) |
         bs.as(:publisher)) |
        flex.as(:flex_type) |
        handbook.as(:type) |
        bip.as(:type) |
        draft.as(:stage) |
        dd.as(:type) |
        pd.as(:type) |
        pas.as(:type) |
        pp.as(:type) |
        na.as(:type) |
        (bs.as(:publisher) >> space >> specialized_prefix) |
        bs.as(:publisher)
      end

      # Number (with optional bracket notation for iterations like 1000[9])
      # Allow alphanumeric for codes like E9111
      rule(:number) { match["0-9A-Z"].repeat(1).as(:number) }

      # Bracket notation for iterations (e.g., 1000[9])
      rule(:bracket_iteration) { str("[") >> match["0-9"].repeat(1).as(:iteration) >> str("]") }

      # Part (can be multi-level like 1-2 or 2.3 with dots, or with letters like F3, or ampersand like 3A & B)
      rule(:part) { dash >> match["0-9A-Za-z.& "].repeat(1).as(:part) }
      rule(:parts) { part.repeat(0).as(:parts) }

      # Space-separated alphanumeric part (for bundled patterns like "9113 N001")
      rule(:space_separated_part) { space >> (match["A-Z"].repeat(1) >> match["0-9"].repeat(1)).as(:part) }

      # Iteration (for formats like BS 1000[9])
      rule(:iteration) { bracket_iteration.repeat(0).as(:iteration) }

      # Year
      rule(:year) { colon >> digit.repeat(4, 4).as(:year) }

      # Base year (year in the base identifier, used when there's a supplement/addendum)
      rule(:base_year) { colon >> digit.repeat(4, 4).as(:base_year) }

      # Month (optional, like :2020-01)
      rule(:month) { dash >> digit.repeat(2, 2).as(:month) }

      # Edition (v1.0, v2.0, etc.) for Flex - lowercase v
      rule(:flex_edition) { space >> str("v") >> match["0-9."].repeat(1).as(:edition) }

      # Edition for IEC/ISO standards (ED2, ED3, etc.) - space before ED, uppercase
      rule(:edition) { space >> str("ED") >> digits.as(:edition) }

      # Amendment (+A1:2008 or /A2:2019 or +A1:15 for short year)
      rule(:amendment) do
        (plus.as(:amd_sep_plus) | slash.as(:amd_sep_slash)) >>
        str("A") >> digits.as(:amd_number) >>
        colon >> digit.repeat(2, 4).as(:amd_year)
      end

      # Corrigendum (+AC:2009 or +AC1:2008 or /AC1:2005 or +C1:2018 or +C1 without year)
      rule(:corrigendum) do
        (plus.as(:amd_sep_plus) | slash.as(:amd_sep_slash)) >>
        str("AC") >> digits.maybe.as(:cor_number) >>
        (colon >> digit.repeat(2, 4).as(:cor_year)).maybe |
        (plus.as(:amd_sep_plus) | slash.as(:amd_sep_slash)) >>
        str("C") >> digits.as(:cor_number) >>
        (colon >> digit.repeat(2, 4).as(:cor_year)).maybe
      end

      # Supplements Document (not amendment/corrigendum supplements, but standalone supplement documents)
      # Forward format: "BS NUMBER:Supplement No. N:YEAR" or "BS NUMBER Supplement N:YEAR"
      # Also handles flex types: "BS CECC 50000:Supplement" or "BS M 31:Supplement"
      # Reverse format: "Supplement No. N (YEAR) to BS NUMBER:YEAR"
      rule(:supplement_document_forward) do
        # With multi-letter flex type prefix (CECC, E9111, etc.)
        (bs.as(:publisher) >> space >> multi_letter_prefix.as(:flex_prefix) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         (colon | space).as(:supp_sep) >> str("Supplement") >> space >> str("No.").as(:supp_no_prefix) >> space >>
         digits.as(:supplement_number) >> colon >> digit.repeat(4, 4).as(:supplement_year)
        ).as(:supplement_document) |
        (bs.as(:publisher) >> space >> multi_letter_prefix.as(:flex_prefix) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         (colon | space).as(:supp_sep) >> str("Supplement") >> space >>
         digits.as(:supplement_number) >> colon >> digit.repeat(4, 4).as(:supplement_year)
        ).as(:supplement_document) |
        # With single-letter flex type prefix (M, etc.)
        (bs.as(:publisher) >> space >> single_letter_prefix.as(:flex_prefix) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         (colon | space).as(:supp_sep) >> str("Supplement") >> space >> str("No.").as(:supp_no_prefix) >> space >>
         digits.as(:supplement_number) >> colon >> digit.repeat(4, 4).as(:supplement_year)
        ).as(:supplement_document) |
        (bs.as(:publisher) >> space >> single_letter_prefix.as(:flex_prefix) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         (colon | space).as(:supp_sep) >> str("Supplement") >> space >>
         digits.as(:supplement_number) >> colon >> digit.repeat(4, 4).as(:supplement_year)
        ).as(:supplement_document) |
        # Without flex type prefix - with "No." prefix
        (bs.as(:publisher) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         (colon | space).as(:supp_sep) >> str("Supplement") >> space >> str("No.").as(:supp_no_prefix) >> space >>
         digits.as(:supplement_number) >> colon >> digit.repeat(4, 4).as(:supplement_year)
        ).as(:supplement_document) |
        # Without "No." prefix
        (bs.as(:publisher) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         (colon | space).as(:supp_sep) >> str("Supplement") >> space >>
         digits.as(:supplement_number) >> colon >> digit.repeat(4, 4).as(:supplement_year)
        ).as(:supplement_document)
      end

      rule(:supplement_document_reverse) do
        # With "No." prefix
        (str("Supplement") >> space >> str("No.").as(:supp_no_prefix) >> space >>
         digits.as(:supplement_number) >> space >> str("(") >> digit.repeat(4, 4).as(:supplement_year) >>
         str(")") >> space >> str("to ") >> bs.as(:publisher) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         colon >> digit.repeat(4, 4).as(:base_year)
        ).as(:supplement_document) |
        # Without "No." prefix
        (str("Supplement") >> space >>
         digits.as(:supplement_number) >> space >> str("(") >> digit.repeat(4, 4).as(:supplement_year) >>
         str(")") >> space >> str("to ") >> bs.as(:publisher) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         colon >> digit.repeat(4, 4).as(:base_year)
        ).as(:supplement_document)
      end

      # Addendum Document
      # Format: "BS NUMBER:Addendum No. N:YEAR" or "BS NUMBER Addendum N:YEAR"
      # Also: "BS NUMBER:YEAR:Addendum No. N:YEAR" or "BS NUMBER:YEARAddendum No. N:YEAR" (space before Addendum)
      # Also handles flex types: "BS CECC 90000:Addendum"
      rule(:addendum_document) do
        # With multi-letter flex type prefix (CECC, E9111, etc.)
        (bs.as(:publisher) >> space >> multi_letter_prefix.as(:flex_prefix) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         (colon | space).as(:add_sep) >> str("Addendum") >> space >> str("No.").as(:add_no_prefix) >> space >>
         digits.as(:addendum_number) >> colon >> digit.repeat(4, 4).as(:addendum_year)
        ).as(:addendum_document) |
        (bs.as(:publisher) >> space >> multi_letter_prefix.as(:flex_prefix) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         (colon | space).as(:add_sep) >> str("Addendum") >> space >>
         digits.as(:addendum_number) >> colon >> digit.repeat(4, 4).as(:addendum_year)
        ).as(:addendum_document) |
        # With single-letter flex type prefix (M, etc.)
        (bs.as(:publisher) >> space >> single_letter_prefix.as(:flex_prefix) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         (colon | space).as(:add_sep) >> str("Addendum") >> space >> str("No.").as(:add_no_prefix) >> space >>
         digits.as(:addendum_number) >> colon >> digit.repeat(4, 4).as(:addendum_year)
        ).as(:addendum_document) |
        (bs.as(:publisher) >> space >> single_letter_prefix.as(:flex_prefix) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         (colon | space).as(:add_sep) >> str("Addendum") >> space >>
         digits.as(:addendum_number) >> colon >> digit.repeat(4, 4).as(:addendum_year)
        ).as(:addendum_document) |
        # With year before Addendum and SPACE separator: "BS NUMBER:YEAR Addendum No. N:YEAR"
        (bs.as(:publisher) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         colon >> digit.repeat(4, 4).as(:base_year) >> space.as(:add_sep) >> str("Addendum") >> space >> str("No.").as(:add_no_prefix) >> space >>
         digits.as(:addendum_number) >> colon >> digit.repeat(4, 4).as(:addendum_year)
        ).as(:addendum_document) |
        # With year before Addendum and COLON separator: "BS NUMBER:YEAR:Addendum No. N:YEAR"
        (bs.as(:publisher) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         colon >> digit.repeat(4, 4).as(:base_year) >> colon.as(:add_sep) >> str("Addendum") >> space >> str("No.").as(:add_no_prefix) >> space >>
         digits.as(:addendum_number) >> colon >> digit.repeat(4, 4).as(:addendum_year)
        ).as(:addendum_document) |
        # Without flex type prefix - with "No." prefix
        (bs.as(:publisher) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         (colon | space).as(:add_sep) >> str("Addendum") >> space >> str("No.").as(:add_no_prefix) >> space >>
         digits.as(:addendum_number) >> colon >> digit.repeat(4, 4).as(:addendum_year)
        ).as(:addendum_document) |
        # Without "No." prefix
        (bs.as(:publisher) >> space >> number.as(:number) >> iteration.as(:iteration) >> parts.as(:parts) >>
         (colon | space).as(:add_sep) >> str("Addendum") >> space >>
         digits.as(:addendum_number) >> colon >> digit.repeat(4, 4).as(:addendum_year)
        ).as(:addendum_document)
      end

      # Bundled Identifiers - Collections of standards published together
      # Separators for bundles
      rule(:bundle_sep_and) { space >> str("and") >> space }
      rule(:bundle_sep_to) { space >> (str("TO") | str("to")).as(:to_case) >> space }
      rule(:bundle_sep_ampersand) { space >> str("&") >> space }
      rule(:bundle_sep_semicolon) { str(";") >> space }
      rule(:bundle_sep_comma) { str(",") }

      rule(:bundle_separator) do
        bundle_sep_and.as(:sep_and) |
        bundle_sep_to.as(:sep_to) |
        bundle_sep_ampersand.as(:sep_ampersand) |
        bundle_sep_semicolon.as(:sep_semicolon) |
        bundle_sep_comma.as(:sep_comma)
      end

      # Parts/Sections bundle like "BS 4048:Parts 1 and 2:1966"
      rule(:parts_bundle) do
        (str("Parts") | str("Sections")).as(:bundle_type) >> space >>
        match["0-9"].repeat(1).as(:part1) >>
        bundle_sep_and >>
        match["0-9."].repeat(1).as(:part2)
      end

      # Single identifier for bundling (without year in some cases)
      # Enhanced to handle space-separated alphanumeric like "9113 N001"
      # IMPORTANT: Order from most specific to least specific
      rule(:bundle_item) do
        # With full BS prefix and multi-letter specialized prefix (for "to" ranges like "BS 2SP 68 to BS 2SP 71")
        (bs.as(:publisher) >> space >> multi_letter_prefix.as(:prefix) >> space >> number >> parts).as(:bundle_item) |
        # With full BS prefix and single-letter specialized prefix
        (bs.as(:publisher) >> space >> single_letter_prefix.as(:prefix) >> space >> number >> parts).as(:bundle_item) |
        # With full BS prefix, number, and space-separated alphanumeric part
        (bs.as(:publisher) >> space >> number >> space_separated_part).as(:bundle_item) |
        # With full BS prefix only
        (bs.as(:publisher) >> space >> number >> parts).as(:bundle_item) |
        # Without BS prefix but with multi-letter prefix (continuing same type)
        (multi_letter_prefix.as(:prefix) >> space >> number >> parts).as(:bundle_item) |
        # Without BS prefix but with single-letter prefix
        (single_letter_prefix.as(:prefix) >> space >> number >> parts).as(:bundle_item) |
        # Number with space-separated alphanumeric part (BEFORE simple number+parts)
        (number >> space_separated_part).as(:bundle_item) |
        # Space-separated alphanumeric parts like "N001" (standalone, for abbreviated forms)
        (match["A-Z"].repeat(1) >> match["0-9"].repeat(1)).as(:bundle_item) |
        # Just number and parts (minimal form - LAST to avoid consuming space-separated)
        (number >> parts).as(:bundle_item)
      end

      # Bundled identifier patterns
      rule(:bundled_identifier) do
        # Parts/Sections format: "BS NUMBER:Parts/Sections N and N:YEAR"
        (publisher_or_type >> space >> number >> colon >> parts_bundle >> year).as(:bundled_parts) |
        # List format with multiple separators: "BS SP 13; 14; 15 and 16:1949"
        (publisher_or_type >> space >> bundle_item >>
         (bundle_separator >> bundle_item).repeat(1) >>
         year.maybe).as(:bundled_list)
      end

      # Supplements
      rule(:supplement) { (amendment | corrigendum).as(:supplement) }
      rule(:supplements) { supplement.repeat(0).as(:supplements) }

      # Expert Commentary suffix - three formats:
      # 1. "Expert Commentary" (full form)
      # 2. "ExComm" (abbreviated form)
      # 3. "ExComm (Fire)" (with optional topic suffix)
      rule(:expert_commentary) do
        space >> (
          (str("Expert Commentary").as(:expert_commentary_full)) |
          (str("ExComm") >> (space >> str("(") >> match["A-Za-z"].repeat(1).as(:expert_commentary_topic) >> str(")")).maybe).as(:expert_commentary)
        )
      end

      # Tracked Changes suffix
      rule(:tracked_changes) { space >> dash >> space >> str("TC").as(:tracked_changes) }

      # PDF suffix
      rule(:pdf_suffix) { space >> str("PDF").as(:pdf) }

      # Translation (captures language name from various formats)
      rule(:translation) do
        space >> str("(") >>
        (
          match["A-Za-z"].repeat(1).as(:translation_lang) >>
          (space >> (str("Translation") | str("version"))).maybe
        ) >>
        str(")") |
        # All-caps format: " SPANISH TRANSLATION" (supplements already parsed)
        space >> (str("SPANISH") | str("FRENCH") | str("GERMAN") | str("ITALIAN")).as(:translation_upper) >> space >> str("TRANSLATION")
      end

      # Collection number (second number after slash like 2035/2030)
      rule(:collection_number) { slash >> digits.as(:second_number) }

      # Adopted standard as opaque string
      # Captures: "EN ISO 8601:2019", "EN IEC 62600:2020", "ISO 8601:2019", "IEC 62600:2020", "EN 10077-1:2006"
      # Also CEN types: "CR 13933:2000", "ES 59008:2000", "ENV 41112:1991", "HD 60269-3", "CWA 13620-5:1999"
      # IMPORTANT: Must NOT capture expert_commentary suffixes - let them be captured separately
      rule(:adopted_org_prefix) do
        str("EN") | str("ISO") | str("IEC") | str("CISPR") | str("CEN") | str("CLC") |
        str("CR") | str("ES") | str("ENV") | str("HD") | str("CWA")
      end

      # Simple adopted string without expert commentary checks (for use in adopted_with_expert_commentary)
      # Use character class that excludes "E" (first letter of "Expert Commentary" and "ExComm")
      # This stops matching before expert commentary suffixes
      rule(:adopted_string_no_expert) do
        adopted_org_prefix >> match("[^E\n]").repeat(1).as(:adopted_string_no_expert)
      end

      # Match content that stops before expert commentary patterns
      rule(:adopted_string_content) do
        (supplement.absent? >> expert_commentary.absent? >> tracked_changes.absent? >> pdf_suffix.absent? >> translation.absent?) >>
          match("[^\n]").repeat(1)
      end

      rule(:adopted_string) do
        (adopted_org_prefix >> adopted_string_content).as(:adopted_string)
      end

      # Bare adopted identifier (no BSI prefix) - starts with ISO/IEC/CISPR
      # IMPORTANT: Order in identifier rule handles this - bare_adopted is tried BEFORE publisher_or_type
      # So we don't need to check for expert_commentary here
      rule(:bare_adopted) do
        (bs.absent? >> adopted_org_prefix >>
         (supplement.absent? >> tracked_changes.absent? >> pdf_suffix.absent? >> translation.absent? >> match("[^\n]")).repeat(0)).as(:adopted_string)
      end

      # Value-Added Publication suffixes (wrapper pattern, not attributes)
      rule(:vapSuffix) do
        (
          space >> str("PDF").as(:pdf_format) |
          space >> str("BOOK").as(:book_format) |
          space >> dash >> space >> str("TC").as(:tc_format)
        )
      end

      # Identifier patterns - try most specific first
      rule(:identifier) do
        # Index identifier - must be before regular identifier
        (bs.as(:publisher) >> space >> number >> index_suffix.as(:index_suffix) >> year).as(:index_identifier) |
        # Supplement Document - reverse format (Supplement No. N (YEAR) to BS...)
        supplement_document_reverse.as(:supplement_document) |
        # Supplement Document - forward format (BS NUMBER:Supplement No. N:YEAR)
        supplement_document_forward |
        # Addendum Document (BS NUMBER:Addendum No. N:YEAR)
        addendum_document |
        # Bundled Identifiers (must be before regular identifiers)
        bundled_identifier |
        # Bare adopted identifier (ISO, IEC without BSI prefix) - check BEFORE adopted_string
        bare_adopted.as(:adopted_string) |
        # Flex with v-style edition before date
        (flex.as(:flex_type) >> space >> number >> parts >> flex_edition.maybe >> (year >> month.maybe).maybe >> supplements) |
        # Regular BSI identifier - VAP suffix at the end
        publisher_or_type >>
        (space >> adopted_string).maybe >>
        (space >> number >> parts >> collection_number.maybe >>
        (year >> month.maybe).maybe >>
        flex_edition.maybe).maybe >>
        supplements.maybe >>
        edition.maybe >>
        expert_commentary.maybe >>
        translation.maybe >>
        vapSuffix.maybe
      end

      rule(:root) { identifier }

      def self.parse(input)
        # Normalize "BSI " to "BS " for consistency, but NOT for "BSI Flex"
        normalized = if input.start_with?("BSI Flex")
                       input  # Keep as is
                     else
                       input.gsub(/\bBSI\s+/, "BS ")
                     end
        new.parse(normalized)
      end
    end
  end
end