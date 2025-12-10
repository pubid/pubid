require "parslet"
require_relative "../parser/common_parse_rules"
require_relative "../parser/common_parse_methods"
require_relative "identifier"
require_relative "supplement_identifier"

module PubidNew
  module Iec
    class Parser < Parslet::Parser
      include ::PubidNew::Parser::CommonParseRules
      include ::PubidNew::Parser::CommonParseMethods

      DASH_CHARS = ["-", "‑", "‐"].freeze

      # We need to sort by length to match longest first because that's how Parslet works
      TYPED_STAGES = PubidNew::Iec::Scheme.typed_stages
        .map(&:abbr).flatten.sort_by(&:length).reverse
      TYPED_STAGES_SUPPLEMENTS = PubidNew::Iec::Scheme.supplement_typed_stages
        .map(&:abbr).flatten.sort_by(&:length).reverse

      root :identifier

      rule(:identifier) do
        working_programme |
          working_document |
          supplement_supplement_identifier |
          standalone_supplement |
          supplement_identifier |
          joint_identifier |
          identifier_copublishers
      end

      # Working Programme format: [PWI|PNW] [TR] number edition
      # Examples: "PWI TR 100-36 ED1", "PWI 100-44 ED1", "PNW 65-915 ED1"
      # TC-style names: "PWI TR SYCSMARTENERGY-1", "PWI SyCLVDC-1 ED1"
      rule(:working_programme) do
        (str("PWI") | str("PNW")).as(:wp_stage) >>
          space >>
          (
            (str("TR") >> space) |
            (str("TS") >> space) |
            (str("SRD") >> space)
          ).maybe.as(:wp_type) >>
          wp_number >>
          (space >> edition).maybe
      end

      # Working programme numbers can be digits or TC names
      rule(:wp_number) do
        # TC-style: SYCSMARTENERGY-1, SyCLVDC-125
        (match('[A-Za-z]').repeat(1) >> match('[A-Za-z\d]').repeat >> (dash >> match('\d').repeat(1)).maybe).as(:number_with_part) |
        # Regular numeric: 100-36
        number_with_part
      end

      # Working Document format: TC/number/stage
      # TC can be: slashes (CIS/D), hyphens (JTC1-SC41), simple (100, 86B, ACEA, SyCSmartEnergy)
      # Examples: "CIS/D/468A/CC", "JTC1-SC41/251/FDIS", "100/3705(F)/FDIS", "86B/4347A/CC"
      rule(:working_document) do
        # TC patterns: digits (100), letters (ACEA), letters/letters (CIS/D), or complex (JTC1-SC41)
        (
          # Try specific patterns first
          (str("JTC1-SC") >> match('\d').repeat(1)) |  # JTC1-SC41
          (match('[A-Z]').repeat(1) >> str("/") >> match('[A-Z]').repeat(1)) |  # CIS/D
          match('[A-Za-z\d]').repeat(1)  # Simple: 100, 86B, ACEA, SyCSmartEnergy
        ).as(:technical_committee) >>
          str("/") >>
          (match('[A-Za-z\d]').repeat(1)).as(:wd_number) >>
          (str("(") >> match('[A-Z]').as(:wd_language) >> str(")")).maybe >>
          (str("/") >> match('[A-Z]').repeat(1).as(:wd_stage)).maybe
      end

      # IEC 60038:2009
      # ISO/IEC 17025:2017
      # CISPR 11:2015 (special IEC publisher)
      # IECQ 080000:2017 (special IEC publisher)
      # IECEE (IEC System for Conformity Assessment)
      # IECEx (IEC System for Certification to Standards)
      # IEC CA (IEC Conformity Assessment)
      # IECQ CS (IECQ Component Specifications)
      # IECQ OD (IECQ Operational Documents)
      rule(:prefix_sole_publisher) do
        (
          str("IECQ OD") |
          str("IECQ CS") |
          str("IEC CA") |
          str("CISPR") |
          str("IECEE") |
          str("IECEx") |
          str("IECQ") |
          str("IEC") |
          str("ISO")
        ).as(:publisher)
      end

      # ISO/IEC or IEC
      rule(:prefix_with_copublishers) do
        prefix_sole_publisher >> space? >> copublishers.maybe
      end

      ORGANIZATIONS = %w[
        IEC ISO IEEE CIW SAE CIE ASME ASTM OECD HL7 CEI UNDP
      ].freeze
      rule(:copublishers) do
        (str("/") >> space? >> array_to_str(ORGANIZATIONS).as(:copublisher)).repeat.as(:copublishers)
      end

      rule(:number_with_part) do
        (number >> part_and_subpart.maybe).as(:number_with_part)
      end

      # For TRF with organization prefix: "CISPR 14-1G" where CISPR is part of the number
      rule(:trf_org_number) do
        (str("CISPR") >> space).as(:trf_org) >> number_with_part
      end

      rule(:number) do
        # Special case for VIM publication
        str("VIM") |
        # Special case for SYMBOL publication
        str("SYMBOL") |
        # IECEx TRF version notation: 62784v1a_ds, 62784v1A
        (match('\d').repeat(1, 6) >> str("v") >> match('\d').repeat(1) >> match('[a-zA-Z]').repeat >> (str("_") >> match('[a-zA-Z]').repeat).maybe) |
        # Can be 5-6 digits for TRF: 60065, 610091
        # Can have letter suffix: 60065N, 610091A
        # Can have letter + underscore + letters: 61215F_SE
        (match('\d').repeat(1, 6) >> (
          match('[A-Z]') >> (str("_") >> match('[A-Z]').repeat).maybe
        ).maybe)
      end

      rule(:date) do
        # :2005-02 or optional for DB without date
        (str(":") | dash) >>
        (year_digits >>
          (dash >> month_digits).maybe >>
          (dash >> day_digits).maybe
        ).as(:date)
      end

      rule(:part_and_subpart) do
        # Parts can have:
        # - Dashes: 60038-1
        # - Complex: 29110-5-1-1
        # - TRF ampersand: 60086-1&2A
        # - TRF underscore: 60127-2-IA_I, 61215F_SE
        # - TRF lowercase: 60127-2-iD_I
        # - TRF commas: 60309-1,2G or 60335-1-14,15G

        # the "space?" needed to handle potential spaces
        (
          (dash | str(",")) >> space? >>
          # matches a part with special TRF characters including commas
          match('[\w&_,]').repeat >>
          # matches subparts
          ((dash | str(",")) >> match('[\w&_,]').repeat).repeat.maybe
        )
      end

      rule(:all_parts) do
        str("(all parts)").as(:all_parts)
      end

      rule(:type_with_stage) do
        # "DTR"
        # "TS"
        # "Guide"
        # Also includes supplement stages like "CDCor" for standalone draft corrigenda
        array_to_str(TYPED_STAGES + TYPED_STAGES_SUPPLEMENTS).as(:type_with_stage) >>
          (match('\d').as(:stage_iteration) >> space).maybe
      end

      rule(:language) do
        # IEC 60038:2009(en,fr)
        # IEC 60038:2009(E/F)
        str("(") >>
          (
            # parse 2-char language codes: ru,en,fr,de,ar,es
            (match["a-z"].repeat(1) >> str(",").maybe) |
            # parse single language codes: R/E/F
            (match["EFARDS"] >> str("/").maybe)
          ).repeat.as(:languages) >>
          str(")")
      end

      EDITION_STRINGS = %w[Edition Ed. ED Ed].freeze
      rule(:edition) do
        # We ignore the case where there is "Ed" but no number
        # Handle decimal editions like ED1.2
        array_to_str(EDITION_STRINGS) >> space? >>
          (digits >> (str(".") >> digits).maybe).maybe.as(:edition)
      end

      rule(:stage_iteration) do
        # "IEC 11243.1"
        str(".") >> match('\d').as(:stage_iteration)
      end

      # Sheet notation: /1:1994 (sheet 1 from year 1994)
      # IEC 60695-2-1/1:1994
      rule(:sheet_notation) do
        str("/") >>
          match('\d').repeat(1).as(:sheet_number) >>
          str(":") >>
          year_digits.as(:sheet_year)
      end

      # VAP suffix for consolidated/version types
      # CSV = Consolidated version (with Supplements)
      # CMV = Compiled Maintenance Version
      # RLV = Redline Version (shows changes)
      # SER = Serial version
      # EXV = Example version
      # PAC = Package
      # PRV = Preview version
      rule(:vap_suffix) do
        space >> (
          str("CSV") |
          str("CMV") |
          str("RLV") |
          str("SER") |
          str("EXV") |
          str("PAC") |
          str("PRV")
        ).as(:vap_suffix)
      end

      # Database suffix: " DB"
      # IEC 60617:2012 DB
      rule(:database_suffix) do
        space >> str("DB").as(:database)
      end

      # Consolidated amendments: +AMD1:2016+AMD2:2019
      # Creates ConsolidatedIdentifier with array of amendments
      rule(:consolidated_supplement) do
        str("+") >>
          (str("AMD") | str("COR")).as(:supplement_type) >>
          match('\d').repeat(1).as(:supplement_number) >>
          str(":") >>
          year_digits.as(:supplement_year)
      end

      rule(:consolidated_supplements) do
        consolidated_supplement.repeat(1).as(:consolidated_supplements)
      end

      rule(:second_part) do
        # Try TRF organization number first, fallback to regular number
        (trf_org_number | number_with_part) >>
          stage_iteration.maybe >>
          (space? >> date | sheet_notation).maybe >>
          consolidated_supplements.maybe >>
          (vap_suffix | database_suffix).maybe
      end

      rule(:third_part_edition) do
        space? >> edition.maybe
      end

      rule(:third_part) do
        # End of the identifier, we can have language, edition, or all parts
        third_part_edition >> language.maybe >> all_parts.maybe
      end

      # prefix sole or copublishers with type and stage
      # IEC/TR 60038
      # ISO/IEC TS 20594-1
      # IEC/FDIS 60038
      rule(:identifier_copublishers) do
        identifier_copublishers_no_third >> third_part
      end

      rule(:guide_prefix) do
        str("Guide") | str("GUIDE")
      end

      rule(:identifier_copublishers_no_third) do
        # Guide IEC 51:1999
        (guide_prefix.as(:type_with_stage_fr) >> space).maybe >>
          prefix_with_copublishers.maybe >> space? >> str("/").maybe >>
          type_with_stage.maybe >>
          space.maybe >>
          second_part >> third_part_edition
      end

      # For joint identifiers (ISO/IEC)
      # ISO/IEC 17025:2017 handles copublisher in copublishers rule
      # We handle this in identifier_copublishers already
      rule(:joint_identifier) do
        identifier_copublishers_no_third.as(:base_identifier) >>
          space? >> str("|") >> space? >>
          scope { iso_identifier }.as(:joint_identifier)
      end

      rule(:iso_identifier) do
        Iso::Parser.new.identifier
      end

      rule(:supplement_type_with_stage) do
        # "DAM"
        # "Amd"
        # "FRAG" (fragments of amendments)
        # "FRAGC" (fragments of corrigenda)
        (array_to_str(TYPED_STAGES_SUPPLEMENTS) | str("FRAGC") | str("FRAG")).as(:type_with_stage)
      end

      # Standalone draft supplement (no base identifier)
      # IEC/FDAM 60038-1
      # IEC/FDCOR 12345
      rule(:standalone_supplement) do
        prefix_with_copublishers >> str("/") >>
          supplement_type_with_stage >>
          space >> second_part >> third_part
      end

      # IEC 60038:2009/Amd 1:2011
      rule(:supplement_identifier_no_third) do
        identifier_copublishers_no_third.as(:base_identifier) >>
          str("/") >> supplement_type_with_stage >>
          space? >> second_part
      end

      rule(:supplement_identifier) do
        supplement_identifier_no_third >> third_part
      end

      # IEC 60038:2009/Amd 1:2011/Cor 1:2012
      rule(:supplement_supplement_identifier) do
        supplement_identifier_no_third.as(:base_identifier) >>
          str("/") >> supplement_type_with_stage >>
          space? >> second_part >> third_part
      end

      rule(:dash) do
        DASH_CHARS.map { |char| str(char) }.reduce(:|)
      end

    end
  end
end