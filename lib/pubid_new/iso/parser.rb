# frozen_string_literal: true

require "parslet"

module PubidNew
  module Iso
    class Parser < Parslet::Parser
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match["A-Z"] }
      rule(:alnum) { match["A-Z0-9"] }
      rule(:alnums) { alnum.repeat(1) }
      rule(:space) { str(" ") }
      rule(:dash) { str("-") | str("‑") | str("‐") }
      rule(:slash) { str("/") }

      # Publishers
      rule(:iso) { str("ISO") }
      rule(:iec) { str("IEC") }
      rule(:ieee) { str("IEEE") }
      rule(:sae) { str("SAE") }
      rule(:astm) { str("ASTM") }
      rule(:cie) { str("CIE") }
      rule(:hl7) { str("HL7") }
      rule(:oecd) { str("OECD") }

      # Publisher with copublishers
      rule(:publisher) do
        iso.as(:publisher) >>
          (slash >> (iec | ieee | sae | astm | cie | hl7 | oecd | str("UNDP")).as(:copublisher)).repeat(
            0, 3
          )
      end

      # Type (including legacy R for Recommendation, TTA for Technology Trends Assessment)
      rule(:type) do
        (str("Guide") | str("GUIDE") | str("ISP") | str("IWA") | str("TTA") |
         str("DATA") | str("DIR") | str("SUP") |
         str("TR") | str("TS") | str("PAS") | str("R")).as(:type)
      end

      # Stage
      rule(:stage) do
        (str("preCD") | str("PreCD") | str("PRECD") |
         str("FDIS") | str("DIS") | str("FCD") |
         str("PRF") | str("NWIP") | str("WD") | str("CD") | str("AWI") | str("NP") | str("PWI")).as(:stage) >>
        digits.maybe.as(:stage_iteration_prefix)
      end

      # Typed stages (combined stage+type)
      rule(:typed_stage) do
        (str("FDAM") | str("FDAMD") | str("PDAM") | str("DAM") | str("DAMD") | str("DAD") |
         str("FDCOR") | str("FCOR") | str("DCOR") |
         str("DTR") | str("DTS") | str("DIS") | str("FDIS") | str("FDTR") | str("FDTS") |
         str("PDTR") | str("PDTS")).as(:typed_stage)
      end

      # Number
      rule(:number) { digits.as(:number) }

      # Part (can be alphanumeric like A01, B02, or just digits)
      rule(:part) { dash >> alnums.as(:part) }

      # Legacy slash-based part (e.g., ISO 31/0-1974)
      rule(:legacy_part) { slash >> alnums.as(:part) }

      # Parts can be either dash-based or slash-based (legacy)
      rule(:parts) { (part | legacy_part).repeat(0).as(:parts) }

      # Edition (can be "Ed 3", "Ed.2", "ED1")
      rule(:edition) do
        (space >> (str("Ed.") | str("Ed ") | str("Ed")) >> space.maybe >> digits.maybe |
         space >> str("ED") >> digits).as(:edition)
      end

      # Year
      rule(:year) { str(":") >> space.maybe >> digit.repeat(4, 4).as(:year) }

      # Legacy year (for ISO/R identifiers that use dash instead of colon)
      rule(:legacy_year) { dash >> digit.repeat(4, 4).as(:year) }

      # Iteration
      rule(:iteration) { str(".") >> digits.as(:iteration) }

      # Language (can be single letters or multi-letter codes, with slashes or commas)
      rule(:language) do
        str("(") >>
          (match["A-Za-z"].repeat(1) >> (str("/") | str(",")).maybe).repeat(1).as(:language) >>
          str(")")
      end

      # Supplement type (longest patterns first for proper Parslet matching)
      rule(:supplement_type) do
        (str("Addendum") | str("Amd.") | str("Add.") |
         str("Amd") | str("AMD") |
         str("Cor.") | str("Cor") | str("COR") |
         str("Suppl") | str("Ext") | str("Add") | str("ADD")).as(:supplement_type)
      end

      # Supplement identifier (appears after base with slash)
      rule(:supplement) do
        slash >> (
          # Pattern 1: Typed stage alone (FDAM implies Amd, FDCOR implies Cor)
          (typed_stage.as(:typed_stage) >> (space >> digits).as(:supplement_number) >> year.maybe >> language.maybe) |
          # Pattern 2: Supplement type with number and optional year/language
          (supplement_type >> (space >> digits).as(:supplement_number) >> year.maybe >> language.maybe) |
          # Pattern 3: Supplement type without number
          (supplement_type >> year.maybe >> language.maybe)
        )
      end

      # IWA pattern (can start without ISO/)
      rule(:iwa_identifier) do
        str("IWA").as(:type) >> space >>
          number >> parts >>
          year.maybe >>
          language.maybe
      end

      # DIR SUP pattern (special directives supplement)
      rule(:dir_sup_identifier) do
        publisher >>
          (slash | space) >> str("DIR").as(:type) >>
          space >> number >> parts >>
          space >> publisher.as(:sup_publisher) >>
          space >> str("SUP").as(:sup_type) >>
          year.maybe
      end

      # Legacy ISO/R identifier (ISO/R number:year or ISO/R number-year or ISO/R number-part:year)
      rule(:legacy_r_identifier) do
        publisher >>
          slash >> str("R").as(:type) >>
          space >> number >>
          (legacy_year | (parts >> (year | legacy_year).maybe)) >>
          language.maybe
      end

      # Basic identifier (can be base or have supplements)
      rule(:base_identifier) do
        publisher >>
          # Typed stage or regular stage
          ((slash | space) >> (typed_stage | stage)).maybe >>
          # Type comes after space or slash
          ((space | slash) >> type).maybe >>
          space >> number >> parts >>
          iteration.maybe >>
          year.maybe >>
          edition.maybe >>
          language.maybe
      end

      # Full identifier with optional supplements
      rule(:identifier) do
        (dir_sup_identifier | iwa_identifier | legacy_r_identifier | base_identifier).as(:base) >>
          supplement.repeat(0, 3).as(:supplements)
      end

      rule(:root) { identifier }

      def self.parse(input)
        # Normalize common typos and variations
        normalized = input
          .gsub(/IS0/, "ISO")              # Zero instead of O
          .gsub(/—/, "/")                   # Em-dash to slash
          .gsub(/–/, "/")                   # En-dash to slash
          .gsub(/\s+:/, ":")                # Whitespace around colons
          .gsub(/\s+\/\s+/, "/")            # Remove spaces around slashes (for supplements)
          .gsub(/ISO\s+\//, "ISO/")         # Remove space before copublisher slash
          .gsub(/\/Add\.\s+/, "/Add ")      # Normalize "Add. " (with space) to "Add "
          .gsub(/\/Add\.(?!\d)/, "/Add")    # Normalize "Add." (without digit) to "Add"

        parser_instance.parse(normalized)
      end

      def self.parser_instance
        @parser_instance ||= new
      end
    end
  end
end
