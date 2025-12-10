# frozen_string_literal: true

require "parslet"
require_relative "../parser/common_parse_rules"
require_relative "../parser/common_parse_methods"

module PubidNew
  module Jcgm
    class Parser < Parslet::Parser
      include ::PubidNew::Parser::CommonParseRules
      include ::PubidNew::Parser::CommonParseMethods

      root :identifier

      rule(:identifier) do
        publisher >> space >> number_portion >> date_portion >> language_portion.maybe
      end

      rule(:publisher) do
        str("JCGM").as(:publisher)
      end

      rule(:number_portion) do
        digits.as(:number)
      end

      rule(:date_portion) do
        str(":") >> year_digits.as(:date)
      end

      # Language: "(E)", "(F)", "(E/F)", "(F/E)"
      rule(:language_portion) do
        str("(") >>
          (
            # Multi-language: E/F, F/E
            (str("E/F") | str("F/E")) |
            # Single language: E, F, R, etc.
            match("[A-Z]")
          ).as(:languages) >>
          str(")")
      end
    end
  end
end