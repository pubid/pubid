module Pubid::Nist
  module Parsers
    class Circ < Default
      rule(:revision) do
        ((str("rev") >> (words >> year_digits | str("")).as(:revision)) |
          (str("r") >> (digits | (words >> year_digits) | str("")).as(:revision))
        )
      end

      rule(:report_number) do
        first_report_number >> edition.maybe >> (str("-") >> second_report_number).maybe
      end

      rule(:edition) do
        # Handle e{digit}rev{Month}{Year} pattern (e.g., e2revJune1908)
        (str("e") >> digits.as(:edition) >>
          str("rev") >> words.as(:revision_month) >> year_digits.as(:revision_year)) |
          # Handle sup{Month}{Year} pattern with optional revision
          (str("sup") >> (
            # supp with date and maybe revision: suppJan1925rev
            (words.as(:edition_month) >> year_digits.as(:edition_year) >> revision.maybe) |
            # supp with just revision: supprev
            (str("").as(:supplement) >> revision)
          )) |
          # Handle e{digit} or -{Month}{Year} patterns
          ((str("e") | str("-")) >> (digits.as(:edition) | words.as(:edition_month) >> year_digits.as(:edition_year)))
      end
    end
  end
end
