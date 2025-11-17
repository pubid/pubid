module PubidNew
  module Plateau
    class Parser < Parslet::Parser
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:hash) { str("#") }

      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }

      # PLATEAU
      rule(:publisher) { str("PLATEAU") }

      # Handbook or Technical Report
      rule(:doc_type) do
        (str("Handbook") | str("Technical Report")).as(:type)
      end

      # Number: #00, #01, #46, etc.
      rule(:number) { hash >> digits.as(:number) }

      # Annex: -1, -2, etc.
      rule(:annex) { dash >> digits.as(:annex) }

      # Edition: 第1.0版, 第2.3版, etc. (only for Handbook)
      rule(:edition_part) do
        str("第") >> 
        (digits >> str(".") >> digits).as(:edition) >> 
        str("版")
      end
      
      rule(:edition) { space >> edition_part }

      # Full identifier patterns
      rule(:handbook) do
        publisher >> space >> doc_type >> space >>
        number >> annex.maybe >> edition.maybe
      end

      rule(:technical_report) do
        publisher >> space >> doc_type >> space >>
        number >> annex.maybe
      end

      rule(:identifier) { handbook | technical_report }

      rule(:root) { identifier }
    end
  end
end