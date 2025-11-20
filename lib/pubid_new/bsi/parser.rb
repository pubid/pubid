require "parslet"

# frozen_string_literal: true

module PubidNew
  module Bsi
    class Parser < Parslet::Parser
      # Basic rules
      rule(:space) { str(" ") }
      rule(:space?) { space.maybe }
      rule(:digit) { match("[0-9]") }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match("[A-Za-z]") }
      rule(:year_full) { digit.repeat(4, 4) }
      rule(:year_short) { digit.repeat(2, 2) }
      rule(:year) { (year_full | year_short).as(:year) }
      rule(:month) { str("-") >> digit.repeat(2, 2).as(:month) }
      rule(:dash) { str("-") }
      rule(:colon) { str(":") }
      rule(:slash) { str("/") }
      rule(:plus) { str("+") }
      rule(:dot) { str(".") }

      # Publishers/Types
      rule(:bsi_type) { (str("BS") | str("PAS") | str("PD") | str("DD") | str("Flex")).as(:type) }
      rule(:bsi_prefix) { str("BSI ").maybe }

      # Version/Edition (for Flex documents)
      rule(:version) { str(" v") >> (digits >> dot >> digits).as(:version) }

      # Collection number (second document in collection like PAS 2035/2030)
      rule(:collection_number) { slash >> digits.as(:collection_number) }

      # Parts
      rule(:part) { dash >> digits.as(:part) }
      rule(:parts) { part.repeat(1).as(:parts) }

      # Supplements
      rule(:supplement_type) { (str("A") | str("C")).as(:supp_type) }
      rule(:amd_number) { str("A") >> digits.as(:amd_number) }
      rule(:cor_number) { str("C") >> digits.as(:cor_number) }
      rule(:amd_year) { colon >> year.as(:amd_year) }
      rule(:cor_year) { colon >> year.as(:cor_year) }

      rule(:amendment) do
        plus >> amd_number >> amd_year.maybe
      end

      rule(:corrigendum) do
        plus >> cor_number >> cor_year.maybe
      end

      rule(:supplement) do
        (amendment | corrigendum).as(:supplement)
      end

      rule(:supplements) { supplement.repeat(0) }

      # ExComm, PDF, TC suffixes
      rule(:excomm) { space >> str("ExComm").as(:excomm) }
      rule(:pdf) { space >> str("PDF").as(:pdf) }
      rule(:tracked_changes) { str(" - TC").as(:tc) }

      # Translation
      rule(:translation_lang) { letter.repeat(1) }
      rule(:translation) do
        space >> (
          (str("(") >> translation_lang.as(:translation) >>
           (space >> (str("Translation") | str("version"))).maybe >> str(")")) |
          (translation_lang.as(:translation) >> str(" TRANSLATION"))
        )
      end

      # Adopted organizations
      rule(:adopted_org) do
        (str("ISO") | str("IEC") | str("EN") | str("CEN") | str("CLC") | str("CISPR")).as(:adopted_org)
      end

      rule(:adopted_org2) do
        slash >> (str("IEC") | str("IEEE")).as(:adopted_org2)
      end

      rule(:adopted_org3) do
        space >> (str("ISO") | str("IEC")).as(:adopted_org3)
      end

      rule(:adopted_org4) do
        slash >> (str("IEC") | str("IEEE")).as(:adopted_org4)
      end

      # Adopted type (TR, TS, etc.) - can be after slash or space
      rule(:adopted_type) do
        (slash | space) >> (str("TR") | str("TS") | str("Guide") |
                  str("PAS") | str("DIS") | str("FDIS") | str("PRF PAS")).as(:adopted_type)
      end

      # Edition marker (ED1, ED2, etc.)
      rule(:edition_marker) do
        space >> str("ED") >> digits.as(:edition)
      end

      # CSV suffix
      rule(:csv_suffix) do
        space >> str("CSV").as(:csv)
      end

      # AMD supplement for IEC
      rule(:amd_supplement) do
        plus >> str("AMD") >> digits.as(:amd_number) >> (colon >> year.as(:amd_year)).maybe
      end

      # Adopted number and parts
      rule(:adopted_number) { digits.as(:adopted_number) }
      rule(:adopted_part) { (digit | dash | dot).repeat(1).as(:adopted_part) }
      rule(:stage_iteration) { dot >> digits.as(:stage_iteration) }

      # Adopted identifier patterns - now with optional edition/CSV/AMD/iteration
      rule(:adopted_with_type) do
        adopted_org >> adopted_type >> space >>
          adopted_number >> stage_iteration.maybe >> (dash >> adopted_part).maybe >>
          (colon >> year >> month.maybe).maybe >>
          amd_supplement.maybe >>
          edition_marker.maybe >>
          csv_suffix.maybe
      end

      rule(:adopted_simple) do
        adopted_org >> adopted_org2.maybe >> space >>
          adopted_number >> stage_iteration.maybe >> (dash >> adopted_part).maybe >>
          (colon >> year >> month.maybe).maybe >>
          amd_supplement.maybe >>
          edition_marker.maybe >>
          csv_suffix.maybe
      end

      rule(:adopted_2level) do
        adopted_org >> adopted_org2.maybe >>
          (adopted_type.maybe) >>
          adopted_org3 >> adopted_org4.maybe >> space >>
          adopted_number >> stage_iteration.maybe >> (dash >> adopted_part).maybe >>
          (colon >> year >> month.maybe).maybe >>
          amd_supplement.maybe >>
          edition_marker.maybe >>
          csv_suffix.maybe
      end

      rule(:adopted) do
        (adopted_with_type | adopted_2level | adopted_simple).as(:adopted)
      end

      # National Annex
      rule(:na_supplements) { supplement.repeat(0) }
      rule(:national_annex) do
        (str("NA") >> na_supplements.as(:supplements) >> str(" to ")).as(:national_annex)
      end

      # Simple identifier (BS/PAS/PD/DD/Flex + number)
      rule(:simple_number) do
        bsi_prefix >> bsi_type >> space >>
          digits.as(:number) >> collection_number.maybe >>
          parts.maybe >> version.maybe >>
          (colon >> year >> month.maybe).maybe
      end

      # Adopted identifier as unparsed string - must start with org name
      rule(:org_prefix) do
        str("ISO") | str("IEC") | str("EN") | str("CEN") | str("CLC") | str("CISPR")
      end

      rule(:adopted_string) do
        # Must start with organization name, then capture rest
        (org_prefix >> (supplement.absent? >> excomm.absent? >> tracked_changes.absent? >>
       translation.absent? >> pdf.absent? >> edition_marker.absent? >>
       match("[^\n]")).repeat(0)).as(:adopted_string)
      end

      # Adopted identifier (BS/PD/DD + adopted string)
      rule(:with_adopted) do
        bsi_type >> space >> adopted_string
      end

      # Standalone adopted (just the adopted string without BS/PD prefix)
      rule(:standalone_adopted) { adopted_string }

      # Main identifier
      rule(:identifier) do
        national_annex.maybe >>
          (simple_number | with_adopted | standalone_adopted) >>
          supplements.as(:supplements) >>
          edition_marker.maybe >>
          excomm.maybe >> tracked_changes.maybe >> translation.maybe >> pdf.maybe
      end

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end