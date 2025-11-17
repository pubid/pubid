require "parslet"
require_relative "../parser/common_parse_rules"
require_relative "../parser/common_parse_methods"
require_relative "identifier"

module PubidNew
  module Jis
    class Parser < Parslet::Parser
      include ::PubidNew::Parser::CommonParseRules
      include ::PubidNew::Parser::CommonParseMethods

      TYPED_STAGES = PubidNew::Jis::Scheme.typed_stages
        .map(&:abbr).flatten.sort_by(&:length).reverse

      root :identifier

      rule(:identifier) do
        base_identifier
      end

      rule(:publisher) do
        str("JIS").as(:publisher)
      end

      rule(:series) do
        match("[A-Z]").as(:series)
      end

      rule(:number) do
        match('\d').repeat(1)
      end

      rule(:part) do
        (str("-") >> match('\d').repeat(1)).repeat(1).as(:part)
      end

      rule(:date) do
        str(":") >> year_digits.as(:date)
      end

      rule(:language) do
        str("(") >> match("[A-Za-z]").repeat(1).as(:language) >> str(")")
      end

      rule(:type_prefix) do
        # TR or TS
        array_to_str(TYPED_STAGES).as(:type_prefix)
      end

      # Base identifier: JIS A 1234-1:1999(E)
      rule(:base_identifier) do
        publisher >> space >>
          type_prefix.maybe >> (space >> str("/")).maybe >> space.maybe >>
          series >> space >>
          number.as(:number) >>
          part.maybe >>
          date.maybe >>
          language.maybe
      end

      rule(:space) do
        str(" ") | str("　")
      end
    end
  end
end