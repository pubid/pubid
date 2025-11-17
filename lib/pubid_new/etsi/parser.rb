module PubidNew
  module Etsi
    class Parser < Parslet::Parser
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:dot) { str(".") }
      rule(:slash) { str("/") }
      rule(:lparen) { str("(") }
      rule(:rparen) { str(")") }

      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:alpha) { match["A-Z"] }
      rule(:alphanum) { match["A-Za-z0-9"] }

      # ETSI
      rule(:publisher) { str("ETSI") }

      # Document types: GS, GR, TS, TR, EN, ES, EG, SR, ETR, ETS, I-ETS, TBR, TCRTR, NET, GTS
      rule(:doc_type) do
        (
          str("I-ETS") |
          str("TCRTR") |
          str("GTS") |
          str("ETR") |
          str("ETS") |
          str("TBR") |
          str("NET") |
          str("GS") |
          str("GR") |
          str("TS") |
          str("TR") |
          str("EN") |
          str("ES") |
          str("EG") |
          str("SR")
        ).as(:type)
      end

      # Number: can be:
      # - Series with dashes + space + 3 digits (e.g., "NFV-IFA 052")
      # - 3 alphanumeric + space + 3 digits (e.g., "ZSM 012")
      # - 3 digits + space + 3 digits (e.g., "300 347")
      # - Just 3 digits (e.g., "273") - without series
      # - GSM XX.XX format (e.g., "GSM 02.01")
      # - Dot notation XX.XX with optional suffix (e.g., "11.40", "11.40-DCS")
      rule(:number) do
        (
          (str("GSM ") >> digit.repeat(2) >> dot >> digit.repeat(2)).as(:number) |
          (digit.repeat(2) >> dot >> digit.repeat(2) >> (dash >> alpha.repeat(1)).maybe).as(:number) |
          ((alphanum.repeat(1) >> (dash >> alphanum.repeat(1)).repeat(1)) >> space >> digit.repeat(3)).as(:number) |
          (alphanum.repeat(3) >> space >> digit.repeat(3)).as(:number) |
          (digit.repeat(3) >> space >> digit.repeat(3)).as(:number) |
          digit.repeat(3).as(:number)
        )
      end

      # Part: -1, -2, -8, etc. Can have multiple parts like -1-2
      rule(:single_part) do
        dash >> (digits | alpha.repeat(3))
      end
      
      rule(:parts) do
        single_part.repeat(1).as(:part)
      end

      # Version: V1.1.1, V2.2.2, V1.2.10, etc. (flexible digits)
      rule(:version) do
        str("V") >> (digits >> dot >> digits >> dot >> digits).as(:version)
      end

      # Edition (old style): ed.1, ed.2
      rule(:edition) do
        str("ed.") >> digits.as(:edition)
      end

      # Date: (2022-12), (1994-10)
      rule(:date) do
        lparen >> (digit.repeat(4) >> dash >> digit.repeat(2)).as(:date) >> rparen
      end

      # Amendment: /A1, /A2
      rule(:amendment) do
        slash >> str("A") >> digits.as(:amendment)
      end

      # Corrigendum: /C1, /C2
      rule(:corrigendum) do
        slash >> str("C") >> digits.as(:corrigendum)
      end

      # Full identifier
      rule(:identifier) do
        publisher >> space >> doc_type >> space >>
        number >> parts.maybe >>
        amendment.maybe >> corrigendum.maybe >> space >>
        (version | edition) >> space >> date
      end

      rule(:root) { identifier }
    end
  end
end