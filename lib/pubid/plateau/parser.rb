# frozen_string_literal: true

module Pubid
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

      # Annex supplement: "Annex A", "Annex B", etc.
      rule(:annex_letter) { match["A-Z"].as(:annex_letter) }
      rule(:annex_supplement) do
        space >> str("Annex") >> space >> annex_letter
      end

      # Full identifier patterns
      rule(:handbook) do
        publisher >> space >> doc_type >> space >>
          number >> annex.maybe >> edition.maybe
      end

      rule(:technical_report) do
        publisher >> space >> doc_type >> space >>
          number >> annex.maybe
      end

      # Annex identifier (supplement)
      rule(:annex_identifier) do
        (handbook | technical_report).as(:base) >> annex_supplement
      end

      rule(:identifier) { annex_identifier | handbook | technical_report }

      rule(:root) { identifier }
    end
  end
end
