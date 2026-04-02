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
            str("A.I.E.E.") |   # With dots variant (no spaces)
            str("A. I. E. E.") | # With dots and spaces variant
            str("AIEE")
          ).as(:publisher)
        end

        # Document types
        rule(:aiee_type) do
          (
            str("Standard No.") |  # AIEE Standard No. 19-1938 (compound type)
            str("Standard No") |   # AIEE Standard No 19-1938 (compound type, no dot)
            str("Std No.") |       # AIEE Std No. 800
            str("Std No") |        # AIEE Std No 800 (no dot)
            str("Std") |           # AIEE Std 800
            str("Nos") |          # NEW Session 171: Plural variant (e.g., "Nos 72 and 73")
            str("No.") |          # AIEE No. 56
            str("No") |           # AIEE No 18 (can be followed by space)
            str("no") |           # AIEE no 700 (lowercase variant)
            str("Standard") |     # AIEE Standard 56
            str("Trans.")         # AIEE Trans. PAS-84
          ).as(:type)
        end

        # Number formats
        rule(:number) do
          (
            # Transaction format: PAS-84, PGI-7
            (upper.repeat(2, 3) >> dash >> digits) |

            # Complex with letter suffix: 27A, 22A, 1E - allow space before dash
            # But don't match if it's actually "Nos 72 and 73" pattern
            (digits >> upper >> (space >> str("and")).absent?) |

            # Decimal number: 750.1, 750.11, 750.5
            (digits >> dot >> digits) |

            # Number with parenthetical variant: 431 (105)
            # Pattern: main number followed by alternate number in parentheses
            (digits.as(:main_number) >> space >> (str("(") >> digits.as(:alt_number) >> str(")")).as(:parenthetical)) |

            # Simple number: 56, 123, 18, 552
            digits >>

            # Handle "Nos X and Y" pattern - we only capture first number
            (space >> str("and") >> space >> digits).absent?
          ).as(:number)
        end

        # Date formats
        # Long form: ", 1956" or ", November 1955" or ". December 1958" or " -1957" (with space)
        # NEW: Also support "May-1928" (month dash year, no comma)
        rule(:date_long) do
          space? >>
            (
              # Format 1: ", Month Year" or ". Month Year"
              ((str(",") | dot).as(:separator) >> space? >>
               (month_name.as(:month) >> space).maybe >> year.as(:year)) |
              # Format 2: " -Year" (space dash year)
              ((space >> dash).as(:separator) >> space? >> year.as(:year)) |
              # Format 3: "Month-Year" (NEW - month dash year, no comma/dot/space prefix)
              (month_name.as(:month) >> dash >> year.as(:year))
            )
        end

        # Short form: "-1962" (directly after number) or " -1958" (with space)
        # ENHANCED: Allow leading space for patterns like "431 (105) -1958"
        rule(:date_short) do
          space.maybe >> dash >> year.as(:year)
        end

        # Combined date rule
        # Try short form first to avoid matching empty prefix in date_long
        rule(:date) do
          (date_short | date_long).maybe
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
