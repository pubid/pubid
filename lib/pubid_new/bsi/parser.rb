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
      
      # Types for native BSI standards
      rule(:pd) { str("PD") }
      rule(:pas) { str("PAS") }
      rule(:na) { str("NA") }
      
      # Stage prefixes
      rule(:draft) { str("Draft BS") | str("DBS") }

      # Adopted organizations - order matters!
      rule(:en) { str("EN") }
      rule(:iso) { str("ISO") }
      rule(:iec) { str("IEC") }
      rule(:cispr) { str("CISPR") }

      # National Annex prefix (special case: "NA to BS...")
      rule(:na_prefix) { str("NA to ").as(:na_prefix) }

      # Publisher/Type - longer patterns first
      rule(:publisher_or_type) do
        na_prefix >>
        (draft.as(:stage) |
         pd.as(:type) |
         bs.as(:publisher)) |
        draft.as(:stage) |
        pd.as(:type) |
        pas.as(:type) |
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

      # Edition (v1.0, v2.0, etc.)
      rule(:edition) { space >> str("v") >> match["0-9."].repeat(1).as(:edition) }

      # Amendment (+A1:2008 or /A2:2019)
      rule(:amendment) do
        (plus.as(:amd_sep_plus) | slash.as(:amd_sep_slash)) >>
        str("A") >> digits.as(:amd_number) >>
        colon >> digit.repeat(4, 4).as(:amd_year)
      end

      # Corrigendum (+AC:2009 or +AC1:2008 or /AC1:2005)
      rule(:corrigendum) do
        (plus.as(:amd_sep_plus) | slash.as(:amd_sep_slash)) >>
        str("AC") >> digits.maybe.as(:cor_number) >>
        colon >> digit.repeat(4, 4).as(:cor_year)
      end

      # Supplements
      rule(:supplement) { (amendment | corrigendum).as(:supplement) }
      rule(:supplements) { supplement.repeat(0).as(:supplements) }

      # Adopted standard as opaque string
      # Captures: "EN ISO 8601:2019", "EN IEC 62600:2020", "ISO 8601:2019", "IEC 62600:2020", "EN 10077-1:2006"
      rule(:adopted_org_prefix) do
        str("EN") | str("ISO") | str("IEC") | str("CISPR")
      end

      rule(:adopted_string) do
        # Capture everything after BS until supplements or end
        (adopted_org_prefix >> (supplement.absent? >> edition.absent? >> match("[^\n]")).repeat(0)).as(:adopted_string)
      end

      # Identifier patterns
      rule(:identifier) do
        publisher_or_type >>
        (space >> adopted_string).maybe >>
        (space >> number >> parts >>
        (year >> month.maybe).maybe >>
        edition.maybe).maybe >>
        supplements
      end

      rule(:root) { identifier }

      def self.parse(input)
        # Normalize "BSI " to "BS "
        normalized = input.gsub(/\bBSI\s+/, "BS ")
        new.parse(normalized)
      end
    end
  end
end