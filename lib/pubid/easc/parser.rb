# frozen_string_literal: true

require "parslet"

module Pubid
  module Easc
    # Parslet grammar for EASC identifiers.
    #
    # Accepts the Cyrillic surface forms observed in mgscatalog.by:
    #
    #   ПМГ 03-2025
    #   ПМГ В 31-2001           (defense variant)
    #   РМГ 151-2025
    #   РМГ 29-2013
    #
    # Also accepts Latin transliterations (PMG, RMG, V) for
    # round-tripping with English-language tooling. The renderer
    # emits Cyrillic as the canonical form.
    class Parser < Parslet::Parser
      include ::Pubid::Parser::CommonParseRules

      root :identifier

      rule(:space)  { str(" ") }
      rule(:space?) { space.maybe }
      rule(:dot)    { str(".") }

      # Year separator: ASCII hyphen OR Unicode em-dash / en-dash,
      # optionally surrounded by whitespace.
      rule(:year_sep) do
        space?.maybe >> (str("-") | str("—") | str("–")) >> space?.maybe
      end

      # Series prefix. Captured to route to the right Identifiers::*
      # subclass (Pmg vs Rmg). Both Cyrillic and Latin forms.
      rule(:series_word) do
        (str("ПМГ") | str("РМГ") | str("PMG") | str("RMG")).as(:series) >> space
      end

      # Defense variant marker — Cyrillic "В" or Latin "V".
      rule(:variant_word) do
        (str("В") | str("V")).as(:variant) >> space
      end

      rule(:prefix) do
        series_word >> variant_word.maybe
      end

      rule(:digits) do
        match("[0-9]").repeat(1)
      end

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
        prefix >> number >> (year_sep >> year).maybe
      end

      def self.parse(string)
        raise ArgumentError, ::Pubid::INPUT_TOO_LONG_MESSAGE if string.length > ::Pubid::MAX_INPUT_LENGTH

        new.parse(string.strip)
      end
    end
  end
end
