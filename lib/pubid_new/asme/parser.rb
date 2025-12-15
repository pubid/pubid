# frozen_string_literal: true

require "parslet"

module PubidNew
  module Asme
    class Parser < Parslet::Parser
      # Basic building blocks
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:slash) { str("/") }
      rule(:dot) { str(".") }
      rule(:digit) { match("[0-9]") }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match("[A-Z]") }
      rule(:letters) { letter.repeat(1) }

      # Publisher
      rule(:publisher) { str("ASME") >> space }

      # Designator (B, Y, BPVC, etc.) - can be multi-letter
      rule(:designator) do
        (
          str("BPVC") |
          str("ISO") |
          str("CSA") |
          str("API") |
          str("ANS") |
          letters
        ).as(:designator)
      end

      # Number part - can be dotted (16.5, III.1.NB, etc.)
      rule(:number_part) do
        (
          match("[0-9A-Z]").repeat(1) >> 
          (dot >> match("[0-9A-Z]").repeat(1)).repeat
        ).as(:number)
      end

      # Year (4-digit)
      rule(:year_4digit) { digit.repeat(4, 4).as(:year) }
      
      # Draft year patterns: 20XX, 202X
      rule(:draft_year) do
        (str("20XX") | str("202X") | (str("20") >> digit >> str("X"))).as(:draft_year)
      end

      # Reaffirmation notation
      rule(:reaffirmation) do
        space >> str("(R") >> year_4digit.as(:reaffirmation) >> str(")")
      end

      # Language notation
      rule(:language) do
        space >> str("(") >> letters.as(:language) >> str(")")
      end

      # CSA dual-published number
      rule(:csa_portion) do
        slash >> str("CSA") >> space >> 
        (letter >> match("[0-9.]").repeat(1)).as(:csa_number)
      end

      # Revision note [Draft Proposed Revision of ...]
      rule(:revision_note) do
        space >> str("[") >> match("[^\\]]").repeat(1).as(:revision_note) >> str("]")
      end

      # Handbook keyword
      rule(:handbook_keyword) { space >> str("Handbook") }

      # Standard identifier
      rule(:standard) do
        publisher >>
        # Optional double ASME for some identifiers
        (publisher >> designator >> slash >> publisher).maybe >>
        # Optional ISO/ prefix
        (str("ISO/ASME") >> space).maybe >>
        designator >>
        number_part >>
        csa_portion.maybe >>
        handbook_keyword.maybe >>
        (
          dash >> (draft_year | year_4digit)
        ).maybe >>
        language.maybe >>
        reaffirmation.maybe >>
        revision_note.maybe
      end

      rule(:identifier) { standard }
      root(:identifier)
    end
  end
end
