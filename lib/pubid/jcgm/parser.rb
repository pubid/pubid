# frozen_string_literal: true

require "parslet"

module Pubid
  module Jcgm
    class Parser < Parslet::Parser
      include ::Pubid::Parser::CommonParseRules
      include ::Pubid::Parser::CommonParseMethods

      root :identifier

      rule(:identifier) do
        meeting_identifier | amendment_identifier | corrigendum_identifier |
          base_identifier | named_guide_identifier
      end

      # "JCGM 200:2008 Corrigendum" — a base guide plus a trailing
      # " Corrigendum" word (no number). Must precede base_identifier: Parslet
      # is an ordered PEG that commits to the first matching alternative, so if
      # base_identifier ran first it would consume "JCGM 200:2008" and root
      # would fail on the leftover " Corrigendum". Emits type_with_stage so the
      # builder routes it to Corrigendum.
      rule(:corrigendum_identifier) do
        base_identifier.as(:base_identifier) >> space >>
          str("Corrigendum").as(:type_with_stage)
      end

      # Dateless "named" guides: "JCGM GUM", "JCGM VIM-3" (and future "VIM-N").
      # Last in the alternation — only reached when base_identifier fully fails
      # (these have no date, so number_portion/date_portion never match).
      rule(:named_guide_identifier) do
        publisher >> space >> named_number
      end

      rule(:named_number) do
        (str("GUM") | (str("VIM") >> (str("-") >> digits).maybe)).as(:number)
      end

      # Committee/meeting record, e.g. "JCGM 17th Meeting (2012)". Diverges
      # from base_identifier right after the digits (base wants ":", meeting
      # wants the ordinal suffix), so ordered choice is unambiguous. Emits the
      # same tokens as a guide plus type_with_stage "Meeting", so the generic
      # builder path resolves it to Identifiers::Meeting (like "Amd").
      rule(:meeting_identifier) do
        publisher >> space >> digits.as(:number) >> ordinal_suffix >>
          space >> str("Meeting").as(:type_with_stage) >> space >>
          str("(") >> year_digits.as(:date) >> str(")")
      end

      rule(:ordinal_suffix) do
        str("st") | str("nd") | str("rd") | str("th")
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
