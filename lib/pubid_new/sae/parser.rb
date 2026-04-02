# frozen_string_literal: true

require "parslet"

module PubidNew
  module Sae
    class Parser < Parslet::Parser
      rule(:space) { str(" ") }
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match["A-Z"] }
      rule(:colon) { str(":") }

      # Publisher
      rule(:publisher) { str("SAE").as(:publisher) }

      # Document types with optional number suffix (e.g., J300, J308A)
      rule(:doc_type) do
        (
          str("AMS") |  # Aerospace Material Specification
          str("AIR") |  # Aerospace Information Report
          str("ARP") |  # Aerospace Recommended Practice
          str("AS") |   # Aerospace Standard
          str("J") |    # SAE Standard (e.g., J300)
          str("MA")     # Material Advisory
        ).as(:type)
      end

      # Number with optional letter prefix or suffix
      rule(:number) do
        (letter.repeat(1, 1) >> digits | digits >> letter.repeat(0, 1)).as(:number)
      end

      # Year
      rule(:year) { digit.repeat(4, 4).as(:year) }

      # Date
      rule(:date) { colon >> year }

      # Main identifier
      rule(:identifier) do
        publisher >> space >> doc_type >> space.maybe >>
          number >> date.maybe
      end

      root(:identifier)

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
