require "parslet"

module PubidNew
  module Itu
    class Parser < Parslet::Parser
      root(:identifier)

      # Basic elements
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:dot) { str(".") }
      rule(:slash) { str("/") }
      
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match["A-Z"] }
      
      # Publisher
      rule(:publisher) { str("ITU") >> space.maybe }
      
      # Sector (T, R, or D)
      rule(:sector) do
        (str("T") | str("R") | str("D")).as(:sector)
      end
      
      # Type (REC for recommendation)
      rule(:rec_type) do
        (dash | space) >> str("REC") >> (dash | space).maybe
      end
      
      # Series letters for ITU-T (single or double letters)
      rule(:t_series) do
        (str("OB") | str("Operational Bulletin") |
         letter >> letter.maybe).as(:series)
      end
      
      # Series letters for ITU-R (single or double letters)
      rule(:r_series) do
        (str("SG") >> digits.as(:sg_number) |
         str("SNG") | str("RR") | str("RRX") | str("RR5") | str("ROP") | str("HFBS") |
         letter >> letter.maybe).as(:series)
      end
      
      # Number (digits, possibly with subseries)
      rule(:number) { digits.as(:number) }
      
      rule(:subseries) do
        dot >> digits.as(:subseries)
      end
      
      # Part (dash followed by part number)
      rule(:part) do
        dash >> digits.as(:part)
      end
      
      # Full number with optional subseries and part
      rule(:full_number) do
        (number >> subseries.repeat(0, 2) >> part.maybe).as(:numbering)
      end
      
      # Second number for combined standards (e.g., G.780/Y.1351)
      rule(:second_number) do
        slash >> t_series >> dot >> full_number
      end
      
      # Range notation (e.g., Q.400-Q.490)
      rule(:range) do
        dash >> t_series.as(:range_series) >> dot >> number.as(:range_number)
      end
      
      # Date in (MM/YYYY) or (YYYY) format
      rule(:month) { digit.repeat(2, 2).as(:month) }
      rule(:year) { digit.repeat(4, 4).as(:year) }
      
      rule(:date) do
        (space >> str("(") >>
         (month >> slash >> year | year) >>
         str(")")).as(:date)
      end
      
      # Supplements, amendments, etc.
      rule(:supplement) do
        space >> str("Suppl.") >> space >> digits.as(:supplement)
      end
      
      rule(:amendment) do
        space >> (str("Amd") | str("Amend")) >> dot.maybe >> space >> digits.as(:amendment)
      end
      
      rule(:annex) do
        space >> str("Annex") >> space >> 
        (letter >> digits.maybe >> str("+").maybe).as(:annex)
      end
      
      rule(:corrigendum) do
        space >> str("Cor.") >> space >> digits.as(:corrigendum)
      end
      
      rule(:addendum) do
        space >> str("Add.") >> space >> digits.as(:addendum)
      end
      
      rule(:appendix) do
        space >> str("App.") >> space >> 
        (str("II") | str("IV") | str("IX") | str("V").repeat(1, 3) | 
         str("X").repeat(0, 3) >> str("I").repeat(0, 3) | 
         digits).as(:appendix)
      end
      
      # No. for Operational Bulletin
      rule(:ob_no) do
        (dot | space >> str("No.") >> space)
      end

      # ITU-T identifier
      rule(:itu_t) do
        (rec_type.maybe >>
         t_series >>
         (ob_no >> full_number | dot >> full_number >> second_number.as(:second_number).maybe >> range.maybe).maybe >>
         date.maybe >>
         supplement.maybe >>
         annex.maybe >>
         amendment.maybe >>
         corrigendum.maybe >>
         addendum.maybe >>
         appendix.maybe).as(:t_content)
      end
      
      # ITU-R identifier
      rule(:itu_r) do
        (rec_type.maybe >>
         (r_series >> (dot >> full_number).maybe |
          full_number).maybe >>
         date.maybe >>
         amendment.maybe).as(:r_content)
      end
      
      # Main identifier rule
      rule(:identifier) do
        publisher >> dash >> sector >>
        (space | dash) >>
        (itu_t | itu_r)
      end
    end
  end
end