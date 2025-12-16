# frozen_string_literal: true

require "parslet"

module PubidNew
  module Csa
    class Parser < Parslet::Parser
      # Basic building blocks
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:slash) { str("/") }
      rule(:colon) { str(":") }
      rule(:comma) { str(",") }
      rule(:dot) { str(".") }
      rule(:ampersand) { str("&") }
      rule(:digit) { match("[0-9]") }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match("[A-Z]") }
      rule(:letters) { letter.repeat(1) }

      # Publisher
      rule(:publisher) { str("CSA") >> space }

      # Code pattern: letter + dotted numbers (e.g., B149.1, C22.2, A123.17)
      rule(:code_pattern) do
        (
          letter >> match("[0-9]").repeat(1) >>
          (dot >> match("[0-9]").repeat(1)).repeat
        ).as(:code)
      end

      # NO. keyword (for C22.2 NO. 286 pattern)
      rule(:no_keyword) { space >> str("NO") >> dot >> space }

      # Number after NO. keyword
      rule(:no_number) { match("[0-9]").repeat(1).as(:no_number) }

      # Year format with optional F or M prefix
      rule(:year_prefix) { (str("F") | str("M")).as(:year_prefix).maybe }
      rule(:year_2digit) { digit.repeat(2, 2) }
      rule(:year_4digit) { digit.repeat(4, 4) }

      # Year with colon (modern format) - mark as colon_year
      rule(:colon_year) do
        colon >> year_prefix >> year_2digit.as(:year) >> str("").as(:colon_format)
      end

      # Year with dash (older format) - mark as dash_year
      rule(:dash_year) do
        dash >> year_prefix >> year_2digit.as(:year) >> str("").as(:dash_format)
      end

      # Reaffirmation notation
      rule(:reaffirmation) do
        space >> str("(R") >> year_4digit.as(:reaffirmation) >> str(")")
      end

      # Package keywords
      rule(:package_keyword) do
        (
          str("Code") | str("Handbook") | str("Training Package") | str("Package")
        )
      end

      # Package portion: "Code, Handbook & Training Package"
      rule(:package_portion) do
        space >>
        package_keyword >>
        (
          (comma >> space >> package_keyword) |
          (space >> ampersand >> space >> package_keyword)
        ).repeat
      end

      # SERIES keyword - can have space before colon
      rule(:series_keyword) do
        (space >> str("SERIES") >> (space.maybe >> colon | colon)).as(:series)
      end

      # Basic CSA identifier
      rule(:csa_code) do
        publisher >>
        code_pattern >>
        (no_keyword >> no_number).maybe >>
        (colon_year | dash_year).maybe >>
        series_keyword.maybe
      end

      # Combined CSA standards with slash
      rule(:combined_slash) do
        csa_code.as(:first) >>
        slash >>
        csa_code.as(:second) >>
        reaffirmation.maybe >>
        package_portion.maybe
      end

      # Combined with comma (CSA B149.1:25, CSA B149.2:25)
      rule(:combined_comma) do
        csa_code.as(:first) >>
        comma >> space >>
        csa_code.as(:second) >>
        (space >> ampersand >> package_portion).maybe
      end

      # Single identifier with optional package
      rule(:single_identifier) do
        csa_code >>
        reaffirmation.maybe >>
        package_portion.maybe
      end

      # Main identifier
      rule(:identifier) do
        combined_slash | combined_comma | single_identifier
      end

      root(:identifier)
    end
  end
end