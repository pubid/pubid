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

      # Annex: -1, -2, etc. Legacy Latin references use "_" as the sub-number
      # separator (e.g. "#46_1"); both render as the canonical dash.
      rule(:annex) { (dash | str("_")) >> digits.as(:annex) }

      # Edition (Handbook only). Canonical form is 第X.Y版; legacy Latin
      # references write the bare X.Y (e.g. "PLATEAU Handbook #00 1.0"). Both
      # capture the same numeric :edition slice, so they build the same object
      # and render to the canonical 第X.Y版.
      rule(:edition_part) do
        str("第") >>
          (digits >> str(".") >> digits).as(:edition) >>
          str("版")
      end

      rule(:edition_latin) { (digits >> str(".") >> digits).as(:edition) }

      rule(:edition) { space >> (edition_part | edition_latin) }

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

      # Technical Report has no edition. A legacy Latin TR reference carrying a
      # trailing edition (e.g. "#00 1.0") is matched by the `handbook` rule
      # (doc_type matches either keyword, tried first); the builder dispatches
      # on :type and drops the captured edition for Technical Report.
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
