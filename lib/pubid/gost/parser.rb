# frozen_string_literal: true

require "parslet"

module Pubid
  module Gost
    # Parslet grammar for GOST identifiers.
    #
    # Accepts the Latin and Cyrillic surface forms observed in the wild:
    #
    #   ГОСТ 14946-82                       (interstate, dated)
    #   ГОСТ 2.312                          (interstate, undated)
    #   ГОСТ Р 71039— 2023                  (national, em-dash + space)
    #   ГОСТ ISO 9692-1                     (copublisher, undated)
    #   ГОСТ Р МЭК 60794-1-23-2017          (Cyrillic copublisher)
    #   ГОСТ Р ИСО/МЭК МФС 10609-9-95      (compound copublisher + subtype)
    #   ГОСТ ISO Guide 30-2019              (copublisher + subtype "Guide")
    #   ГОСТ Р 58904-2020/ISO/TR 25901-1:2016  (IDT adoption, slash form)
    #
    # The parser captures three atoms:
    #   * :scope_r     — "R"/"Р" if Russian national, nil if interstate
    #   * :prefix_text — everything between scope_r and the number
    #                     (copublisher, subtype, or both) as a raw string
    #   * :raw         — digit runs separated by dots/dashes (number+year)
    #   * :adopted_raw — the foreign identifier after "/" (IDT adoption)
    #
    # The builder interprets prefix_text (splits copublisher vs subtype,
    # normalizes Cyrillic to Latin) and raw (splits number vs year).
    class Parser < Parslet::Parser
      include ::Pubid::Parser::CommonParseRules

      root :identifier

      rule(:space)  { str(" ") }
      rule(:space?) { space.maybe }
      rule(:dot)    { str(".") }

      rule(:year_sep) do
        (str("-") | str("—") | str("–")) >> space?.maybe
      end

      rule(:gost_word) do
        (str("GOST") | str("ГОСТ")).as(:gost_word) >> space
      end

      rule(:scope_r) do
        (match("R") | match("Р")).as(:scope_r) >> space
      end

      # Everything between scope_r and the first digit: copublisher,
      # subtype, or both. Captured as a raw string — the builder splits
      # it into copublisher + subtype. Matches uppercase letters (Latin
      # and Cyrillic), forward slashes, and spaces between words.
      rule(:prefix_text) do
        (match("[A-ZА-Яa-zа-я/]").repeat(1) >>
          (space >> match("[A-ZА-Яa-zа-я/]").repeat(1)).repeat).as(:prefix_text) >> space
      end

      rule(:digits) do
        match("[0-9]").repeat(1)
      end

      rule(:raw_body) do
        (digits >> ((dot | year_sep) >> digits).repeat).as(:raw)
      end

      # IDT adoption suffix: "/<foreign-identifier>". The slash is
      # consumed but NOT captured — only the foreign identifier text
      # goes into :adopted_raw. Captures everything after the first
      # slash, including subsequent slashes (the adopted identifier
      # may itself contain slashes, e.g. "ISO/TR 25901-1:2016").
      rule(:adopted_part) do
        str("/") >> match(".").repeat(1).as(:adopted_raw)
      end

      # Adoption reference in parens: "(<foreign-id>)". The parens
      # themselves are consumed but NOT captured. The content goes
      # into :adopted_reference_raw. This form appears for MOD/NEQ
      # adoptions where the foreign standard is referenced but not
      # identical (IDT would use the slash form instead).
      rule(:adopted_reference_part) do
        space?.maybe >> str("(") >> match("[^)]").repeat(1).as(:adopted_reference_raw) >> str(")")
      end

      rule(:identifier) do
        gost_word >> scope_r.maybe >> prefix_text.maybe >> raw_body >>
          adopted_part.maybe >> adopted_reference_part.maybe
      end

      def self.parse(string)
        raise ArgumentError, ::Pubid::INPUT_TOO_LONG_MESSAGE if string.length > ::Pubid::MAX_INPUT_LENGTH

        new.parse(string.strip)
      end
    end
  end
end
