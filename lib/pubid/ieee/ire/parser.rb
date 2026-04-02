# frozen_string_literal: true

require "parslet"

module Pubid
  module Ieee
    module Ire
      # Parser for IRE (Institute of Radio Engineers) identifiers
      # Historical period: 1912-1963 (merged into IEEE in 1963)
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

        # Year pattern - handle both 2-digit (52 = 1952) and 4-digit (1952) formats
        rule(:year_short) do
          # 2-digit year: 12-63 (1912-1963 IRE period)
          match("[1-6]") >> digit
        end

        rule(:year_full) do
          # 4-digit year for IRE period: 1912-1963
          (str("191") >> digit.repeat(1, 1)) | # 1912-1919
            (str("19") >> (str("2") | str("3") | str("4") | str("5")) >> digit) | # 1920-1959
            (str("196") >> match("[0-3]")) # 1960-1963
        end

        rule(:year) { year_full | year_short }

        # IRE prefix variations
        rule(:ire_prefix) do
          (
            str("IEEE-IRE") | # Transitional period (1963-1965)
            str("IRE")
          ).as(:publisher)
        end

        # Document types
        rule(:ire_type) do
          (
            str("Trans.") |       # IRE Trans. PGI-7
            str("Standard") |     # IRE Standard
            str("Std")            # IRE Std
          ).as(:type)
        end

        # Number formats
        rule(:number) do
          (
            # Complex format with spaces: 28 S1, 15.S1, 7.S2
            (digits >> (space | dot) >> upper >> digits) |

            # Complex format: 1.IRE62.1S1
            (digits >> dot >> str("IRE") >> digits >> dot >> digits >> upper >> digits) |

            # Transaction format: PGI-7, PGAP-4
            (upper.repeat(2, 4) >> dash >> digits) |

            # Simple number: 56, 123
            digits
          ).as(:number)
        end

        # Date (year only for IRE)
        rule(:date) do
          (space? >> (dash | str(",")).maybe >> space? >> year.as(:year)).maybe
        end

        # Complete IRE identifier - YEAR FIRST format
        rule(:ire_identifier) do
          # Format: "52 IRE 7.S2" or "1952 IRE 7.S2"
          year.as(:year) >>
            space >>
            ire_prefix >>
            space >>
            (ire_type >> space).maybe >>
            number >>
            (space? >> (dash | str(",")).maybe >> space? >> year_full.as(:full_year)).maybe
        end

        root(:ire_identifier)
      end
    end
  end
end
