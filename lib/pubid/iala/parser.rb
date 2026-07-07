# frozen_string_literal: true

require "parslet"

module Pubid
  module Iala
    # Parslet grammar for IALA identifiers.
    #
    # Accepts every shape that appears on the IALA website or cover page:
    #
    #   S1070
    #   S1070 Ed 2.0
    #   IALA S1070 Ed 2.0
    #   S1070 Ed 2.0 (F)
    #   R1016:ed2.0(F)
    #   C0103-1
    #   C0103-1 Ed 3.0
    class Parser < Parslet::Parser
      include ::Pubid::Parser::CommonParseRules

      root :identifier

      rule(:space)  { str(" ") }
      rule(:space?) { space.maybe }
      rule(:dash)   { str("-") }
      rule(:colon)  { str(":") }
      rule(:dot)    { str(".") }
      rule(:lparen) { str("(") }
      rule(:rparen) { str(")") }

      # Type letter — one of IALA's seven document classes. Captured to
      # route to the right Identifiers::* subclass.
      rule(:type_letter) do
        (str("S") | str("R") | str("G") | str("M") |
         str("C") | str("X") | str("P")).as(:type_letter)
      end

      # 4-digit document number, e.g. "1070", "0126".
      rule(:doc_number) do
        match("[0-9]").repeat(4, 4).as(:doc_number)
      end

      # Numeric sub-part suffix(es): "-1", "-9-10", "-11". The catalogue
      # uses ranges like R0124-9-10 & 11 — that compound is captured
      # verbatim and resolved by the caller, not here.
      rule(:subpart) do
        (dash >> digits.as(:subpart_number)).repeat(1).as(:subpart)
      end

      rule(:code) do
        type_letter >> doc_number >> subpart.maybe
      end

      # Edition forms observed on covers and listing pages:
      #   " Ed 2.0"      — cover-page human form
      #   ":ed2.0"       — listing-page compact form
      rule(:edition_human) do
        (space >> str("Ed") >> space >> edition_value).as(:edition)
      end

      rule(:edition_compact) do
        (colon >> str("ed") >> edition_value).as(:edition)
      end

      rule(:edition_value) do
        (digits >> (dot >> digits).repeat).as(:edition_value)
      end

      rule(:edition) do
        edition_human | edition_compact
      end

      # Language is a single uppercase letter inside parens: (E), (F), …
      rule(:language) do
        (space? >> lparen >>
          (str("E") | str("F") | str("S") | str("C") | str("A") | str("R")).as(:language) >>
          rparen).as(:language_group)
      end

      # Optional "IALA " prefix.
      rule(:publisher) do
        (str("IALA") >> space).maybe
      end

      rule(:identifier) do
        publisher >> code >> edition.maybe >> language.maybe
      end

      # Parse a string and return the raw parslet tree.
      # @param string [String]
      # @return [Hash]
      def self.parse(string)
        raise ArgumentError, "IALA identifier string exceeds maximum length" if string.length > ::Pubid::MAX_INPUT_LENGTH

        new.parse(string.strip)
      end
    end
  end
end
