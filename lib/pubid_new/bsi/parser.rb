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

      # Flex documents (BSI Flex or just Flex) - BSI is already normalized to BS
      rule(:flex) { str("BSI Flex") | str("BS Flex") | str("Flex") }

      # Types for native BSI standards
      rule(:dd) { str("DD") }
      rule(:pd) { str("PD") }
      rule(:pas) { str("PAS") }
      rule(:na) { str("NA") }
      rule(:handbook) { str("Handbook") }
      rule(:pp) { str("PP") }
      rule(:bip) { str("BIP") }

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
        bs.as(:publisher)
      end

      # Number
      rule(:number) { digits.as(:number) }

      # Part (can be multi-level like 1-2)
      rule(:part) { dash >> match["0-9-"].repeat(1).as(:part) }
      rule(:parts) { part.repeat(0).as(:parts) }

      # Year
      rule(:year) { colon >> digit.repeat(4, 4).as(:year) }

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

      # Supplements
      rule(:supplement) { (amendment | corrigendum).as(:supplement) }
      rule(:supplements) { supplement.repeat(0).as(:supplements) }

      # Expert Commentary suffix
      rule(:expert_commentary) { space >> str("ExComm").as(:expert_commentary) }

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
      rule(:adopted_org_prefix) do
        str("EN") | str("ISO") | str("IEC") | str("CISPR") | str("CEN") | str("CLC") |
        str("CR") | str("ES") | str("ENV") | str("HD") | str("CWA")
      end

      rule(:adopted_string) do
        # Capture everything after BS until supplements, suffixes, or end (but edition is OK inside)
        (adopted_org_prefix >> (supplement.absent? >> expert_commentary.absent? >> tracked_changes.absent? >> pdf_suffix.absent? >> translation.absent? >> match("[^\n]")).repeat(0)).as(:adopted_string)
      end

      # Bare adopted identifier (no BSI prefix) - starts with ISO/IEC/CISPR
      rule(:bare_adopted) do
        adopted_org_prefix >> (supplement.absent? >> expert_commentary.absent? >> tracked_changes.absent? >> pdf_suffix.absent? >> translation.absent? >> match("[^\n]")).repeat(0)
      end

      # Value-Added Publication suffixes (wrapper pattern, not attributes)
      rule(:vap_suffix) do
        (
          space >> str("PDF").as(:pdf_format) |
          space >> str("BOOK").as(:book_format) |
          space >> dash >> space >> str("TC").as(:tc_format)
        )
      end

      # Identifier patterns - try most specific first
      rule(:identifier) do
        # Bare adopted identifier (ISO, IEC without BSI prefix)
        bare_adopted.as(:adopted_string) |
        # Flex with v-style edition before date
        (flex.as(:flex_type) >> space >> number >> parts >> flex_edition.maybe >> (year >> month.maybe).maybe >> supplements) |
        # Regular BSI identifier - VAP suffix at the end
        publisher_or_type >>
        (space >> adopted_string).maybe >>
        (space >> number >> parts >> collection_number.maybe >>
        (year >> month.maybe).maybe >>
        flex_edition.maybe).maybe >>
        supplements >>
        edition.maybe >>
        expert_commentary.maybe >>
        translation.maybe >>
        vap_suffix.maybe
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