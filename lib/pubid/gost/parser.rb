# frozen_string_literal: true

require "parslet"

module Pubid
  module Gost
    # Parslet grammar for GOST identifiers.
    #
    # Accepts the Latin and Cyrillic surface forms:
    #
    #   GOST 14946-82
    #   GOST R 34.12-2015
    #   GOST R 8.595-2004
    #   ГОСТ Р 34.11-94
    #   ГОСТ 14946-82
    #
    # The optional "R" / "Р" marker is captured as `:scope_r`; the
    # builder translates that into `scope: "russian"` (its absence
    # means interstate, scope: nil).
    class Parser < Parslet::Parser
      include ::Pubid::Parser::CommonParseRules

      root :identifier

      rule(:space)  { str(" ") }
      rule(:space?) { space.maybe }
      rule(:dash)   { str("-") }
      rule(:dot)    { str(".") }

      # The "GOST" word — Latin OR Cyrillic. Captured to keep the parse
      # tree uniform; the builder ignores the literal (publisher is
      # always rendered as "GOST" / "ГОСТ" based on context, defaulting
      # to Latin).
      rule(:gost_word) do
        (str("GOST") | str("ГОСТ")).as(:gost_word) >> space
      end

      # Russian-national scope marker — Latin "R" or Cyrillic "Р".
      rule(:scope_r) do
        (match("R") | match("Р")).as(:scope_r) >> space
      end

      rule(:prefix) do
        gost_word >> scope_r.maybe
      end

      rule(:digits) do
        match("[0-9]").repeat(1)
      end

      # GOST numbers are digit runs optionally dotted ("34.12", "8.595",
      # "1.0"). Captured as a single string attribute.
      rule(:number) do
        (digits >> (dot >> digits).repeat).as(:number)
      end

      rule(:year_2digit) do
        match("[0-9]").repeat(2, 2)
      end

      rule(:year_4digit) do
        match("[0-9]").repeat(4, 4)
      end

      rule(:year) do
        (year_4digit | year_2digit).as(:year)
      end

      rule(:identifier) do
        prefix >> number >> (dash >> year).maybe
      end

      def self.parse(string)
        raise ArgumentError, ::Pubid::INPUT_TOO_LONG_MESSAGE if string.length > ::Pubid::MAX_INPUT_LENGTH

        new.parse(string.strip)
      end
    end
  end
end
