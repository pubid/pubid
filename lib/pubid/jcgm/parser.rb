# frozen_string_literal: true

require "parslet"

module Pubid
  module Jcgm
    class Parser < Parslet::Parser
      include ::Pubid::Parser::CommonParseRules
      include ::Pubid::Parser::CommonParseMethods

      root :identifier

      rule(:identifier) do
        amendment_identifier | base_identifier
      end

      rule(:base_identifier) do
        publisher >> space >> number_portion >> date_portion >> language_portion.maybe
      end

      rule(:amendment_identifier) do
        base_identifier.as(:base_identifier) >>
          str("/") >> amendment_type >>
          space >> amendment_number >>
          amendment_date.maybe
      end

      rule(:publisher) do
        str("JCGM").as(:publisher)
      end

      # Number can be plain (100, 200) or GUM-prefixed (GUM-1, GUM-6)
      rule(:number_portion) do
        gum_number | standard_number
      end

      rule(:standard_number) do
        digits.as(:number)
      end

      rule(:gum_number) do
        str("GUM-") >> digits.as(:gum_number)
      end

      # Date can be YYYY or YYYY-MM-DD
      rule(:date_portion) do
        str(":") >> (full_date | year_only)
      end

      rule(:year_only) do
        year_digits.as(:date)
      end

      rule(:full_date) do
        (year_digits >> str("-") >> month_digits >> str("-") >> day_digits).as(:date)
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

      # Amendment support
      rule(:amendment_type) do
        str("Amd").as(:type_with_stage)
      end

      rule(:amendment_number) do
        digits.as(:iteration)
      end

      rule(:amendment_date) do
        str(":") >> (full_date | year_only)
      end
    end
  end
end
