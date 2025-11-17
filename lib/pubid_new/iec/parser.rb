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
        supplement_supplement_identifier |
          supplement_identifier |
          joint_identifier |
          identifier_copublishers
      end

      # IEC 60038:2009
      # ISO/IEC 17025:2017
      rule(:prefix_sole_publisher) do
        (str("IEC") | str("ISO")).as(:publisher)
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

      rule(:number) do
        match('\d').repeat(1, 5)
      end

      rule(:date) do
        # :2005-02
        (str(":") | dash) >>
        (year_digits >>
          (dash >> month_digits).maybe >>
          (dash >> day_digits).maybe
        ).as(:date).maybe
      end

      rule(:part_and_subpart) do
        # Modern parts
        # IEC 60038-1:2009
        # ISO/IEC 29110-5-1-1

        # the "space?" needed to handle potential spaces
        (
          dash >> space? >>
          # matches a part
          match('\w').repeat >>
          # matches a subpart
          (dash >> match('\w').repeat).repeat.maybe
        )
      end

      rule(:all_parts) do
        str("(all parts)").as(:all_parts)
      end

      rule(:type_with_stage) do
        # "DTR"
        # "TS"
        # "Guide"
        array_to_str(TYPED_STAGES).as(:type_with_stage) >>
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
        array_to_str(EDITION_STRINGS) >> space? >> digits.maybe.as(:edition)
      end

      rule(:stage_iteration) do
        # "IEC 11243.1"
        str(".") >> match('\d').as(:stage_iteration)
      end

      rule(:second_part) do
        number_with_part >>
          stage_iteration.maybe >>
          space? >> date.maybe
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
        array_to_str(TYPED_STAGES_SUPPLEMENTS).as(:type_with_stage)
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