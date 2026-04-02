require "parslet"
# frozen_string_literal: true
require_relative "../parser/common_parse_rules"
require_relative "../parser/common_parse_methods"
require_relative "identifier"

module PubidNew
  module Idf
    class Parser < Parslet::Parser
      include ::PubidNew::Parser::CommonParseRules
      include ::PubidNew::Parser::CommonParseMethods

      # We need to sort by length to match longest first because that's how Parslet works
      TYPED_STAGES = PubidNew::Idf::Scheme.typed_stages
        .map(&:abbr).flatten.sort_by(&:length).reverse
      TYPED_STAGES_SUPPLEMENTS = PubidNew::Idf::Scheme.supplement_typed_stages
        .map(&:abbr).flatten.sort_by(&:length).reverse

      root :identifier

      rule(:identifier) do
        supplement_identifier |
          identifier_publisher
      end

      # IDF 125A:1988
      rule(:prefix_sole_publisher) do
        str("IDF").as(:publisher)
      end

      rule(:number_with_part) do
        (number >> part_and_subpart.maybe).as(:number_with_part)
      end

      # IDF identifiers can contain alphanumeric characters
      # IDF 125A:1988
      rule(:number) do
        match('\w').repeat(1, 5)
      end

      rule(:date) do
        (year_digits >>
          (dash >> month_digits).maybe >>
          (dash >> day_digits).maybe
        ).as(:date)
      end

      rule(:part_and_subpart) do
        # IDF 80-1:2001
        # the "space?" needed to handle "ISO/TS 10303- 1751:2014"
        (
          dash >> space? >>
          # matches a part
          match('\w').repeat >>
          # matches a subpart, e.g. "A01" or "1-2" (yes we treat {5}-{1-1} as part and subpart)
          (dash >> match('\w').repeat).repeat.maybe
        )
      end

      rule(:all_parts) do
        str("(all parts)").as(:all_parts)
      end

      rule(:type_with_stage) do
        # IDF/RM 82:2004
        # IDF/RM 254:2022
        array_to_str(TYPED_STAGES).as(:type_with_stage) >>
          (match('\d').as(:stage_iteration) >> space).maybe
      end

      rule(:language) do
        # IDF/RM 82:2004(en,fr)
        str("(") >>
          (
            # parse 2-char language codes: ru,en,fr,de,ar,es
            (match["a-z"].repeat(1) >> str(",").maybe) |
            # parse single language codes: R/E/F
            (match["EFARDS"] >> str("/").maybe)
          ).repeat.as(:languages) >>
          str(")")
      end

      rule(:stage_iteration) do
        # "ISO 11243.1"
        str(".") >> match('\d').as(:stage_iteration)
      end

      rule(:second_part) do
        number_with_part >>
          stage_iteration.maybe >>
          space? >> (
            # :2005-02
            (str(":") >> date)
          ).maybe
      end

      rule(:third_part) do
        # End of the identifier, we can have language, or all parts
        space? >> language.maybe >> all_parts.maybe
      end

      # prefix sole publishers with type and stage
      # IDF/RM 82:2004
      rule(:identifier_publisher) do
        identifier_publisher_no_third >> third_part
      end

      rule(:identifier_publisher_no_third) do
        prefix_sole_publisher >> space? >> str("/").maybe >>
          type_with_stage.maybe >>
          space.maybe >>
          second_part
      end

      rule(:supplement_type_with_stage) do
        # "AMD" or "COR"
        array_to_str(TYPED_STAGES_SUPPLEMENTS).as(:type_with_stage)
      end

      # IDF 148-1:2008 / COR 1:2009
      # IDF 140-1:2007 / AMD1:2012 (no space between AMD and 1)
      rule(:supplement_identifier_no_third) do
        identifier_publisher_no_third.as(:base_identifier) >>
          space? >> str("/") >> space? >>
          supplement_type_with_stage >>
          space.maybe >> second_part
      end

      rule(:supplement_identifier) do
        supplement_identifier_no_third >> third_part
      end

      # # ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017
      # # ISO/IEC 19794-7:2014/Amd 1:2015/CD Cor 1
      # rule(:supplement_supplement_identifier) do
      #   supplement_identifier_no_third.as(:base_identifier) >>
      #     str("/") >> supplement_type_with_stage >>
      #     # digits.as(:stage_iteration).maybe >>
      #     space? >> second_part >> third_part
      # end

      rule(:dash) do
        str("-") | str("‑") | str("‐")
      end
    end
  end
end
