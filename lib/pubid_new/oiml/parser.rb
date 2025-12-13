# frozen_string_literal: true

require "parslet"
require_relative "../parser/common_parse_rules"
require_relative "../parser/common_parse_methods"

module PubidNew
  module Oiml
    class Parser < Parslet::Parser
      include ::PubidNew::Parser::CommonParseRules
      include ::PubidNew::Parser::CommonParseMethods

      root :identifier

      # Additional basic rules not in CommonParseRules
      rule(:colon) { str(":") }
      rule(:lparen) { str("(") }
      rule(:rparen) { str(")") }
      rule(:slash) { str("/") }

      # Main identifier pattern
      rule(:identifier) do
        publisher >>
        doc_type >>
        full_number >>
        date.maybe >>
        draft_stage.maybe >>
        language_portion.maybe
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

      # Date - year after colon
      rule(:date) { colon >> year_digits.as(:year) }

      # Draft stage - WD or CD with optional iteration
      rule(:stage_iteration) do
        (
          digits >> str(".") >> digits |  # 3.1
          digits                           # 1, 2, 3
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
        match("[EFRX]")  # Single letter: E, F, R, X
      end

      rule(:lang_multi) do
        match("[a-z]").repeat(2, 2)  # Two letters: en, fr, etc.
      end

      rule(:language_code) do
        (
          lang_single >> slash >> lang_single |  # E/F
          lang_single |                          # E, F
          lang_multi                             # en, fr
        ).as(:language)
      end

      rule(:language_portion) do
        lparen >> language_code >> rparen
      end
    end
  end
end