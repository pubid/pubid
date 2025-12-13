# frozen_string_literal: true

require "parslet"

module PubidNew
  module Ieee
    module Aiee
      # Parser for AIEE (American Institute of Electrical Engineers) identifiers
      # Historical period: 1884-1963 (merged into IEEE in 1963)
      class Parser < Parslet::Parser
        # Basic building blocks
        rule(:space) { str(" ") }
        rule(:space?) { space.maybe }
        rule(:dash) { str("-") }
        rule(:dot) { str(".") }
        rule(:digit) { match("[0-9]") }
        rule(:digits) { digit.repeat(1) }
        rule(:letter) { match("[A-Za-z]") }
        rule(:upper) { match("[A-Z]") }

        # Year pattern (for AIEE period: 1884-1963)
        rule(:year) do
          (str("18") >> digit.repeat(2, 2)) | # 1884-1899
          (str("19") >> (str("0") | str("1") | str("2") | str("3") | str("4") | str("5")) >> digit) | # 1900-1959
          (str("196") >> match("[0-3]")) # 1960-1963
        end

        # Month patterns
        rule(:month_name) do
          str("January") | str("February") | str("March") | str("April") |
          str("May") | str("June") | str("July") | str("August") |
          str("September") | str("October") | str("November") | str("December") |
          str("Jan") | str("Feb") | str("Mar") | str("Apr") | str("Jun") |
          str("Jul") | str("Aug") | str("Sep") | str("Sept") | str("Oct") | str("Nov") | str("Dec")
        end

        # AIEE prefix variations
        rule(:aiee_prefix) do
          (
            str("IEEE-AIEE") |  # Transitional period (1963-1965)
            str("AIEE")
          ).as(:publisher)
        end

        # Document types
        rule(:aiee_type) do
          (
            str("No.") |          # AIEE No. 56
            str("No") >> space.absent? |  # AIEE No 18 (without dot, followed by space)
            str("Standard") |     # AIEE Standard 56
            str("Trans.")         # AIEE Trans. PAS-84
          ).as(:type)
        end

        # Number formats
        rule(:number) do
          (
            # Transaction format: PAS-84, PGI-7
            (upper.repeat(2, 3) >> dash >> digits) |

            # Complex with letter suffix: 27A, 22A (WITHOUT dash to year)
            (digits >> upper) |

            # Simple number: 56, 123, 18, 552
            digits
          ).as(:number)
        end

        # Date formats
        # Long form: ", 1956" or ", November 1955" or ". December 1958"
        rule(:date_long) do
          space? >> (str(",") | dot).as(:separator) >> space? >>
          (month_name.as(:month) >> space).maybe >>
          year.as(:year)
        end

        # Short form: "-1962" (directly after number)
        rule(:date_short) do
          dash >> year.as(:year)
        end

        # Combined date rule
        rule(:date) do
          (date_long | date_short).maybe
        end

        # Complete AIEE identifier
        rule(:aiee_identifier) do
          aiee_prefix >>
          space >>
          aiee_type >>
          space >>
          number >>
          date
        end

        root(:aiee_identifier)
      end
    end
  end
end