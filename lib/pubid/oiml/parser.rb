# frozen_string_literal: true

require "parslet"

module Pubid
  module Oiml
    class Parser < Parslet::Parser
      include ::Pubid::Parser::CommonParseRules
      include ::Pubid::Parser::CommonParseMethods

      root :identifier

      # Additional basic rules not in CommonParseRules
      rule(:colon) { str(":") }
      rule(:lparen) { str("(") }
      rule(:rparen) { str(")") }
      rule(:slash) { str("/") }

      # Main identifier pattern - check supplements first
      rule(:identifier) do
        amendment_identifier | amendment_short | annex_letter_identifier | annex_identifier | base_identifier
      end

      # Publisher - always "OIML"
      rule(:publisher) { str("OIML").as(:publisher) >> space }

      # Document type - single letter
      rule(:doc_type) { match("[BDEGRSVX]").as(:type) >> space }

      # Number with optional part and subpart
      rule(:number_only) { digits.as(:number) }

      rule(:part_number) { dash >> digits.as(:part) }

      rule(:subpart_number) { dash >> digits.as(:subpart) }

      rule(:full_number) do
        (
          number_only >> part_number >> subpart_number |
          number_only >> part_number |
          number_only
        )
      end

      # Edition number - ordinal numbers
      rule(:edition_number) do
        (
          str("6th") | str("5th") | str("4th") | str("3rd") |
          str("2nd") | str("1st") |
          (digits >> (str("th") | str("nd") | str("rd") | str("st")))
        ).as(:edition)
      end

      # Edition text - uppercase or lowercase
      rule(:edition_text) { str("Edition") | str("edition") }

      # Edition portion - handles "6th Edition 2015" or "Edition 2013" or ", edition 1992"
      rule(:edition_portion) do
        (
          (str(", ") | space) >>
          edition_number.maybe >> space.maybe >> edition_text >> space.maybe >> year_digits.as(:year)
        ).as(:edition_format) # Wrap entire match to capture that Edition was used
      end

      # Date - year after colon OR edition portion (with optional space before year)
      rule(:date) do
        edition_portion | (colon >> space.maybe >> year_digits.as(:year))
      end

      # Draft stage - WD or CD with optional iteration
      rule(:stage_iteration) do
        (
          digits >> str(".") >> digits | # 3.1
          digits # 1, 2, 3
        ).as(:iteration)
      end

      rule(:stage_abbr) do
        (str("WD") | str("CD")).as(:stage)
      end

      rule(:draft_stage) do
        space >> stage_iteration.maybe >> stage_abbr
      end

      # Language codes
      rule(:lang_single) do
        match("[EFRX]") # Single letter: E, F, R, X
      end

      rule(:lang_multi) do
        match("[a-z]").repeat(2, 2) # Two letters: en, fr, etc.
      end

      rule(:language_code) do
        (
          lang_single >> slash >> lang_single |  # E/F
          lang_single |                          # E, F
          lang_multi                             # en, fr
        ).as(:language)
      end

      rule(:language_with_space) do
        space >> lparen >> language_code >> rparen >> str("").as(:space_before_lang)
      end

      rule(:language_without_space) do
        lparen >> language_code >> rparen
      end

      rule(:language_portion) do
        language_with_space | language_without_space
      end

      # Amendment identifier - "Amendment (YYYY) to BASE"
      rule(:amendment_identifier) do
        str("Amendment") >> space >> lparen >> year_digits.as(:year) >> rparen >>
          space >> str("to") >> space >>
          base_without_language.as(:base_identifier) >>
          language_portion.maybe.as(:language)
      end

      # Short amendment forms - "OIML TYPE NUMBER Amendment Edition YYYY" or "Amendment: YYYY"
      rule(:amendment_short) do
        publisher >>
          doc_type >>
          full_number.as(:base_code) >>
          space >> str("Amendment").as(:amd_marker) >>
          (
            (space >> edition_text >> space.maybe >> year_digits.as(:year)).as(:edition_format) |
            (colon >> space.maybe >> year_digits.as(:year))
          ) >>
          language_portion.maybe.as(:language)
      end

      # Annex identifier - "BASE Annexes Edition YYYY" or "BASE Annexes:YYYY"
      rule(:annex_identifier) do
        base_without_language.as(:base_identifier) >>
          space >> str("Annexes").as(:annex_marker) >>
          (
            (space >> edition_text >> space >> year_digits.as(:year)).as(:edition_format) |
            (colon >> year_digits.as(:year))
          ) >>
          language_portion.maybe.as(:language)
      end

      # Annex with letter - "BASE Annex A Edition YYYY"
      rule(:annex_letter_identifier) do
        base_without_language.as(:base_identifier) >>
          space >> str("Annex") >> space >> match("[A-Z]").as(:annex_letter) >>
          (space >> edition_text >> space >> year_digits.as(:year) | colon >> year_digits.as(:year)).maybe >>
          language_portion.maybe.as(:language)
      end

      # Base identifier without language (for use in supplements)
      rule(:base_without_language) do
        publisher >>
          doc_type >>
          full_number >>
          date.maybe >>
          draft_stage.maybe
      end

      # Base identifier for recursion and standalone parsing
      rule(:base_identifier) do
        publisher >>
          doc_type >>
          full_number >>
          date.maybe >>
          draft_stage.maybe >>
          language_portion.maybe
      end
    end
  end
end
