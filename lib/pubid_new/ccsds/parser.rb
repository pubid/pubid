require "parslet"
require_relative "../parser/common_parse_rules"
require_relative "../parser/common_parse_methods"
require_relative "identifier"
require_relative "supplement_identifier"

module PubidNew
  module Ccsds
    class Parser < Parslet::Parser
      include ::PubidNew::Parser::CommonParseRules
      include ::PubidNew::Parser::CommonParseMethods

      root :identifier

      rule(:identifier) do
        corrigendum_identifier | base_identifier
      end

      # CCSDS 123.1-B-1
      # CCSDS A123.1-G-2-S
      rule(:base_identifier) do
        str("CCSDS") >> space >>
          series.maybe >>
          number >>
          part >>
          book_color >>
          edition.maybe >>
          retired.maybe >>
          language.maybe
      end

      # Optional series letter before number
      rule(:series) do
        match['A-Z'].as(:series)
      end

      rule(:number) do
        digits.as(:number)
      end

      # Part with dot notation: .1 or .12
      rule(:part) do
        str(".") >> digits.as(:part)
      end

      # Book color: -B, -G, -M, -Y, -O, -R
      rule(:book_color) do
        str("-") >> match['BGMYOR'].as(:book_color)
      end

      # Edition: -1, -2, -1.1
      rule(:edition) do
        str("-") >> (digits >> (str(".") >> digits).maybe).as(:edition)
      end

      # Retired marker
      rule(:retired) do
        str("-S").as(:retired)
      end

      # Language translation marker
      rule(:language) do
        space >> str("- ") >> match['\w'].repeat(1).as(:language) >> space >> str("Translated")
      end

      # Corrigendum: CCSDS 123.1-B-1 Cor. 1
      rule(:corrigendum_identifier) do
        base_identifier.as(:base_identifier) >>
          space >> str("Cor. ") >> digits.as(:corrigendum_number)
      end
    end
  end
end