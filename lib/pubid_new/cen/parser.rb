require "parslet"
require_relative "../parser/common_parse_rules"
require_relative "../parser/common_parse_methods"
require_relative "identifier"
require_relative "supplement_identifier"

module PubidNew
  module Cen
    class Parser < Parslet::Parser
      include ::PubidNew::Parser::CommonParseRules
      include ::PubidNew::Parser::CommonParseMethods

      DASH_CHARS = ["-", "‑", "‐", "/"].freeze

      TYPED_STAGES = PubidNew::Cen::Scheme.typed_stages
        .map(&:abbr).flatten.sort_by(&:length).reverse
      TYPED_STAGES_SUPPLEMENTS = PubidNew::Cen::Scheme.supplement_typed_stages
        .map(&:abbr).flatten.sort_by(&:length).reverse

      root :identifier

      rule(:identifier) do
        bundled_identifier |
          supplement_identifier |
          base_identifier
      end

      # CEN organizations: EN, CEN, CLC (CENELEC)
      ORGANIZATIONS = %w[EN CEN CLC].freeze
      
      rule(:publisher) do
        array_to_str(ORGANIZATIONS).as(:publisher)
      end

      rule(:copublishers) do
        (str("/") >> array_to_str(ORGANIZATIONS).as(:copublisher)).repeat.as(:copublishers)
      end

      rule(:prefix) do
        publisher >> copublishers.maybe
      end

      rule(:stage_prefix) do
        # prEN, FprEN
        (str("pr") | str("Fpr")).as(:stage)
      end

      rule(:number_with_part) do
        (number >> part_and_subpart.maybe).as(:number_with_part)
      end

      rule(:number) do
        match('\d').repeat(1, 5)
      end

      rule(:part_and_subpart) do
        # EN 10077-1
        # EN ISO 29110-5-1-1
        (
          dash >> 
          match('\w').repeat >>
          (dash >> match('\w').repeat).repeat.maybe
        )
      end

      rule(:date) do
        str(":") >>
        (year_digits >>
          (dash >> month_digits).maybe >>
          (dash >> day_digits).maybe
        ).as(:date)
      end

      rule(:type_with_stage) do
        # Array of all typed stages: TS, TR, CWA, HD, Guide
        array_to_str(TYPED_STAGES).as(:type_with_stage)
      end

      rule(:supplement_type_with_stage) do
        # A (Amendment), AC (Corrigendum)
        array_to_str(TYPED_STAGES_SUPPLEMENTS).as(:type_with_stage)
      end

      # Base identifier without bundled supplements
      # EN 10077-1:2006
      # CEN TS 1234:2010
      # prEN 15316-1:2020
      # CWA 17145-2:2017
      rule(:base_identifier_no_date) do
        # Stage prefix case: prEN, FprEN
        ((stage_prefix >> str("EN")).as(:type_with_stage) >> space >> number_with_part) |
        # Type-as-publisher case: CWA
        (array_to_str(%w[CWA HD]).as(:type_with_stage) >> space >> number_with_part) |
        # Regular case: EN, CEN, CLC with optional type
        (prefix >> (space >> type_with_stage).maybe >> space >> number_with_part)
      end

      rule(:base_identifier) do
        base_identifier_no_date >> date.maybe
      end

      # Supplement identifier: EN 10077-1:2006/AC:2009
      rule(:supplement_part) do
        supplement_type_with_stage >>
          number.as(:supplement_number).maybe >>
          date.maybe
      end

      rule(:supplement_identifier_no_supplements) do
        base_identifier.as(:base_identifier) >>
          str("/") >> supplement_part
      end

      rule(:supplement_identifier) do
        supplement_identifier_no_supplements >>
          # Can have additional supplements: /AC2:2010
          (str("/") >> supplement_part).repeat
      end

      # Bundled identifier: EN 10077-1:2006+AC:2009+AC2:2009
      # This is the critical CEN pattern
      rule(:bundled_supplement) do
        supplement_type_with_stage >>
          number.as(:supplement_number).maybe >>
          date
      end

      rule(:bundled_identifier) do
        base_identifier.as(:base_document) >>
          (
            str("+") >> 
            bundled_supplement.as(:supplement)
          ).repeat(1).as(:supplements)
      end

      rule(:dash) do
        DASH_CHARS.map { |char| str(char) }.reduce(:|)
      end
    end
  end
end