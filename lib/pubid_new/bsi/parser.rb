require "parslet"

module PubidNew
  module Bsi
    class Parser < Parslet::Parser
      root(:identifier)

      # Basic building blocks
      rule(:space) { str(" ") }
      rule(:space?) { space.maybe }
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:alpha) { match["A-Z"] }

      # Year and month
      rule(:year) { digit.repeat(2, 4).as(:year) }
      rule(:month) { digit.repeat(2).as(:month) }

      # Document types
      rule(:bs_type) { str("BS") }
      rule(:pas_type) { str("PAS") }
      rule(:pd_type) { str("PD") }
      rule(:dd_type) { str("DD") }
      rule(:bsi_flex) { str("BSI") >> space >> str("Flex") }
      rule(:flex_type) { str("Flex") }

      rule(:doc_type) do
        (bsi_flex.as(:type) | 
         flex_type.as(:type) |
         pas_type.as(:type) |
         pd_type.as(:type) |
         dd_type.as(:type) |
         bs_type.as(:type))
      end

      # National Annex prefix
      rule(:na_supplement) do
        (str("+A") >> digits.as(:amd_number) >> (str(":") >> year).maybe.as(:amd_year)) |
        (str("+C") >> digits.as(:cor_number) >> (str(":") >> year).maybe.as(:cor_year))
      end

      rule(:national_annex) do
        (str("NA").as(:na_type) >> na_supplement.maybe.as(:na_supplement) >> 
         space >> str("to") >> space).as(:national_annex)
      end

      # Numbers and parts
      rule(:number) { digits.as(:number) }
      rule(:part) { str("-") >> digits.as(:part) }
      rule(:second_number) { str("/") >> digits.as(:second_number) }

      # Edition (for Flex)
      rule(:edition) { space >> str("v") >> (digits >> str(".") >> digits).as(:edition) }

      # Year-month
      rule(:year_with_month) { year >> (str("-") >> month).maybe }

      # Supplements
      rule(:amendment) do
        str("+A") >> digits.as(:amd_number) >> (str(":") >> year).maybe.as(:amd_year)
      end

      rule(:corrigendum) do
        str("+C") >> digits.as(:cor_number) >> (str(":") >> year).maybe.as(:cor_year)
      end

      rule(:supplement) { (amendment | corrigendum).as(:supplement) }

      # Expert Commentary
      rule(:expert_commentary) { space >> str("ExComm").as(:expert_commentary) }

      # Tracked Changes
      rule(:tracked_changes) { space >> str("-") >> space >> str("TC").as(:tracked_changes) }

      # Translation
      rule(:translation) do
        space >> (
          (str("(") >> match["[A-Za-z]"].repeat(1).as(:translation) >> 
           (space >> (str("Translation") | str("version"))).maybe >> str(")")) |
          (match["[A-Z]"].repeat(1).as(:translation) >> space >> str("TRANSLATION"))
        )
      end

      # PDF
      rule(:pdf) { space >> str("PDF").as(:pdf) }

      # Adopted content - captures everything until supplement/expert/translation/pdf/TC
      rule(:adopted_content) do
        (supplement.absent? >> expert_commentary.absent? >> translation.absent? >>
         pdf.absent? >> tracked_changes.absent? >> any).repeat(1).as(:adopted)
      end

      # Standard number component
      rule(:standard_number) do
        number >> second_number.maybe >> part.maybe >> edition.maybe >>
        (str(":") >> year_with_month).maybe
      end

      # Main identifier structure
      rule(:identifier) do
        national_annex.maybe >>
        (str("BSI") >> space).maybe >>
        doc_type >> space >>
        (
          # Try standard number first
          standard_number |
          # Otherwise it's an adopted document
          adopted_content
        ) >>
        supplement.repeat.as(:supplements) >>
        expert_commentary.maybe >>
        tracked_changes.maybe >>
        translation.maybe >>
        pdf.maybe
      end
    end
  end
end