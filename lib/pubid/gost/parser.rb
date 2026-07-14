# frozen_string_literal: true

require "parslet"

module Pubid
  module Gost
    # Parslet grammar for GOST identifiers.
    #
    # Accepts the Latin and Cyrillic surface forms observed in the wild
    # (incl. the KSM catalogue at new-shop.ksm.kz):
    #
    #   GOST 14946-82
    #   GOST R 34.12-2015
    #   ГОСТ Р 34.11-94
    #   ГОСТ Р 71039— 2023              (em-dash + space)
    #   ГОСТ IEC 62550-2025             (joint adoption — copublisher IEC)
    #   ГОСТ EN 14179-1-2024            (joint adoption, subpart + year)
    #   ГОСТ ISO 17635-2018             (joint adoption — copublisher ISO)
    #
    # The optional "R" / "Р" marker is captured as `:scope_r`; the
    # builder translates that into `scope: "russian"` (its absence
    # means interstate, scope: nil). The optional copublisher word is
    # captured as `:copublisher`.
    #
    # The number-with-optional-year is captured as a single `:raw` atom
    # (digit runs separated by dots, dashes, em-dashes, en-dashes).
    # The builder splits it into `number` + `year` because the
    # disambiguation between subpart dashes (`14179-1`) and year
    # separators (`14946-82`) is context-dependent and easier done
    # with a regex than a PEG rule.
    class Parser < Parslet::Parser
      include ::Pubid::Parser::CommonParseRules

      root :identifier

      rule(:space)  { str(" ") }
      rule(:space?) { space.maybe }
      rule(:dot)    { str(".") }

      # Separators allowed inside the raw number-with-year: ASCII hyphen,
      # Unicode em-dash (U+2014), Unicode en-dash (U+2013). Each may be
      # followed by optional whitespace (KSM emits "ГОСТ Р 71039— 2023").
      rule(:sep) do
        (str("-") | str("—") | str("–")) >> space?.maybe
      end

      rule(:gost_word) do
        (str("GOST") | str("ГОСТ")).as(:gost_word) >> space
      end

      rule(:scope_r) do
        (match("R") | match("Р")).as(:scope_r) >> space
      end

      # Joint-adoption copublisher — a foreign SDO whose standard GOST
      # republishes. Latin and Cyrillic forms both appear.
      rule(:copublisher_word) do
        (str("IEC") | str("ISO") | str("EN") | str("ASTM") |
         str("IEEE") | str("CISPR") | str("CEN") | str("CENELEC") |
         str("МЭК") | str("ИСО") | str("ЕН") | str("МЭК") |
         str("ИСО/МЭК") | str("ISO/IEC")).as(:copublisher) >> space
      end

      rule(:prefix) do
        gost_word >> scope_r.maybe >> copublisher_word.maybe
      end

      rule(:digits) do
        match("[0-9]").repeat(1)
      end

      # Raw body: digit runs separated by dots or dashes/em-dashes.
      # Captured as a single atom and split into number+year by the
      # builder.
      rule(:raw_body) do
        (digits >> ((dot | sep) >> digits).repeat).as(:raw)
      end

      rule(:identifier) do
        prefix >> raw_body
      end

      def self.parse(string)
        raise ArgumentError, ::Pubid::INPUT_TOO_LONG_MESSAGE if string.length > ::Pubid::MAX_INPUT_LENGTH

        new.parse(string.strip)
      end
    end
  end
end
