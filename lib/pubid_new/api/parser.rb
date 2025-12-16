# frozen_string_literal: true

require "parslet"

module PubidNew
  module Api
    class Parser < Parslet::Parser
      # Basic building blocks
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:slash) { str("/") }
      rule(:colon) { str(":") }
      rule(:dot) { str(".") }
      rule(:digit) { match("[0-9]") }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match("[A-Z]") }
      rule(:letters) { letter.repeat(1) }

      # Publisher
      rule(:publisher) { str("API") >> space }

      # Document types (longest first for proper matching)
      rule(:doc_type) do
        (
          str("MPMS") |
          str("BULL") |
          str("SPEC") |
          str("STD") |
          str("RP") |
          str("TR") |
          str("COS") |
          str("PUBL")
        ).as(:type)
      end

      # Chapter notation for MPMS (e.g., "CH 10")
      rule(:chapter_notation) do
        space >> str("CH") >> space >> digits.as(:chapter)
      end

      # Number with optional part (e.g., "579-2", "1104", "6D", "D16", "17TR7")
      # Allow any mix of digits and letters
      rule(:number_with_part) do
        match("[0-9A-Z]").repeat(1).as(:number) >>
        (dash >> match("[0-9A-Z]").repeat(1).as(:part)).maybe
      end

      # Year (4-digit)
      rule(:year) { digit.repeat(4, 4).as(:year) }

      # Date with dash (e.g., "-2023")
      rule(:date_dash) { dash >> year }

      # Date with colon (e.g., ":2023")
      rule(:date_colon) { colon >> year }

      # Reaffirmation notation (e.g., "(R2020)")
      rule(:reaffirmation) do
        space >> str("(R") >> year >> str(")")
      end

      # MPMS identifier (special format with CH)
      rule(:mpms_identifier) do
        publisher >>
        str("MPMS").as(:type) >>
        chapter_notation >>
        (dot >> digits.as(:section)).maybe >>
        (dot >> digits.as(:subsection)).maybe >>
        (date_dash | date_colon).maybe
      end

      # Standard identifier with type
      rule(:typed_identifier) do
        publisher >>
        doc_type >> space >>
        number_with_part >>
        (date_dash | date_colon).maybe >>
        reaffirmation.maybe
      end

      # Typeless identifier (just API + number)
      rule(:typeless_identifier) do
        publisher >>
        number_with_part >>
        (date_dash | date_colon).maybe >>
        reaffirmation.maybe
      end

      # Main identifier (try MPMS first, then typed, then typeless)
      rule(:identifier) do
        mpms_identifier | typed_identifier | typeless_identifier
      end

      root(:identifier)
    end
  end
end