# frozen_string_literal: true

require "parslet"

module PubidNew
  module Itu
    class Parser < Parslet::Parser
      # Basic elements
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match["A-Z"] }
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:dot) { str(".") }

      # ITU prefix
      rule(:itu_prefix) { str("ITU") >> (dash | space) }

      # Sector (R, T, or D)
      rule(:sector) do
        (str("R") | str("T") | str("D")).as(:sector)
      end

      # Series (BO, V, X, etc.)
      rule(:series) do
        (
          # Study groups: SG1, SG12
          (str("SG") >> digits) |
          # Regular series: BO, V, X, etc.
          letter.repeat(1, 3)
        ).as(:series)
      end

      # Number
      rule(:number) do
        digits.as(:number)
      end

      rule(:subseries) do
        dot >> digits.as(:subseries)
      end

      # Parts
      rule(:part) do
        dash >> digits.as(:part)
      end

      rule(:parts) { part.repeat(0).as(:parts) }

      # Code = number + subseries + parts
      rule(:code) do
        number >> subseries.maybe >> parts
      end

      # Date
      rule(:date_part) do
        space >> str("(") >>
          (digits.as(:month) >> str("/")).maybe >>
          digit.repeat(4, 4).as(:year) >>
          str(")")
      end

      # Language
      rule(:language) do
        dash >> match["EFASCR"].as(:language)
      end

      # With series: ITU-R BO.600-1
      rule(:with_series) do
        itu_prefix >>
          sector >>
          space >>
          series >> dot >>
          code >>
          date_part.maybe >>
          language.maybe
      end

      # Without series: ITU-R 20-200
      rule(:without_series) do
        itu_prefix >>
          sector >>
          space >>
          code >>
          date_part.maybe >>
          language.maybe
      end

      rule(:identifier) { with_series | without_series }

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end