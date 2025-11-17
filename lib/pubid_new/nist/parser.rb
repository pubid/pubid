# frozen_string_literal: true

require "parslet"

module PubidNew
  module Nist
    # Parser class for NIST identifiers
    # Single Responsibility: Parsing NIST identifier syntax
    class Parser < Parslet::Parser
      # Basic building blocks
      rule(:space) { str(" ") }
      rule(:dot) { str(".") }
      rule(:dash) { str("-") }
      rule(:slash) { str("/") }
      rule(:digit) { match("[0-9]") }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match("[A-Za-z]") }
      rule(:upper_letter) { match("[A-Z]") }
      rule(:lower_letter) { match("[a-z]") }

      # Publisher
      rule(:publisher) do
        (str("NBS") | str("NIST")).as(:publisher)
      end

      # Compound series (include publisher in series name) - must be checked FIRST
      rule(:compound_series) do
        (
          # Compound series starting with NBS (longest first!)
          str("NBS BRPD-CRPL-D") | str("NBS CRPL-F-A") | str("NBS CRPL-F-B") |
          str("NBS CS-E") | str("NBS CIS") | str("NBS HR") |
          str("NBS IRPL") | str("NBS IP") | str("NBS LC") | str("NBS PS") |
          # Compound series starting with NIST
          str("ITL Bulletin") | str("NIST LC") | str("NIST PS") | str("NIST DCI") |
          str("NIST Other") |
          # Compound series with CSRC
          str("CSRC Building Block") | str("CSRC Use Case") | str("CSRC Book") |
          # Compound with NSRDS
          str("NSRDS-NBS")
        ).as(:series)
      end
      
      # Simple series (no publisher prefix)
      rule(:simple_series) do
        (
          str("AMS") | str("BSS") | str("BMS") | str("BH") |
          str("FIPS") | str("GCR") | str("HB") | str("MONO") |
          str("MP") | str("NCSTAR") | str("NSRDS") | str("IR") |
          str("SP") | str("TN") | str("CSWP") | str("VTS") |
          str("AI") | str("CIRC") | str("CS") | str("CSM") |
          str("CRPL") | str("OWMWP") | str("PC") | str("RPT") |
          str("SIBS") | str("TIBM") | str("TTB") | str("EAB") |
          str("JPCRD") | str("JRES")
        ).as(:series)
      end

      # Number patterns - allow letters and digits
      # Suffix letter only if NOT followed by digit (prevents consuming 'e2', 'r1', etc.)
      rule(:number_suffix) { match("[aA-Z]") }
      
      rule(:digits_with_suffix) do
        digits >> 
          # Suffix only if not followed by digit (e.g., don't match 'e' in '140e2')
          (number_suffix >> digit.absent?).maybe
      end
      
      # Report number - first part
      rule(:first_number) do
        digits_with_suffix.as(:first_number)
      end

      # Second number (after dash)
      rule(:second_number) do
        (
          # Special patterns like "NCNR", "PERMIS", "BFRL"
          str("NCNR") | str("PERMIS") | str("BFRL") |
          # Regular number with optional suffix
          digits_with_suffix
        ).as(:second_number)
      end

      # Full report number
      rule(:report_number) do
        first_number >> (dash >> second_number).maybe
      end

      # Volume
      rule(:volume) do
        (str("v") | str(" Vol. ")) >> (digits >> (str("a-l") | str("m-z")).maybe >> upper_letter.repeat).as(:volume)
      end

      # Part
      rule(:part) do
        (str("pt") | str("p") | str("P") | str(" Part ")) >>
          (digits >> (dash >> digits).maybe).as(:part)
      end

      # Revision
      rule(:revision) do
        ((str(" rev ") | str("rev") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
          (digits >> lower_letter.maybe).maybe).as(:revision)
      end

      # Version
      rule(:version) do
        ((str("ver") | str(" Ver. ") | str(" Version ") | str("v")) >>
          (digits >> (dot >> digits).repeat).maybe).as(:version)
      end

      # Edition with different formats
      rule(:edition) do
        (
          # Edition with year and month: e201801, e2018 (4-digit year)
          (str("e") >> match("[0-9]").repeat(4, 4).as(:edition_year) >> match("[0-9]").repeat(2, 2).as(:edition_month).maybe) |
          # Edition number with dash and year: e2-1915, e3-2020
          ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >> dash >> digits.as(:edition_year)) |
          # Edition with dash and year: -2018, -Jan2018
          (dash >> (
            (match("[A-Za-z]").repeat(3, 3).as(:edition_month) >> digits.as(:edition_year)) |
            digits.as(:edition_year) |
            (match("[A-Za-z]").repeat(3, 3).as(:edition_month) >> match("[0-9]").repeat(2, 2).as(:edition_day) >>
              slash >> digits.as(:edition_year))
          )) |
          # Edition with e prefix: e2, e3 (1-3 digits, NOT 4)
          ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition))
        )
      end

      # Update
      rule(:update) do
        ((str("/Upd") | str("/upd") | str("-upd")) >>
          (digits.as(:update_number) >> (dash >> digits.as(:update_year)).maybe)).as(:update)
      end

      # Addendum
      rule(:addendum) do
        ((str("-add") | str(".add") | str(" Add.")) >>
          (space | dash).maybe >> (digits | str("")).as(:addendum_number)).as(:addendum)
      end

      # Supplement - "supp" or "sup" followed by optional letters/digits
      # Capture only the suffix part (or empty string if no suffix)
      # Support both uppercase and lowercase for month names like "supJan1924"
      rule(:supplement) do
        (str("supp") | str("sup")) >> match("[A-Za-z0-9]").repeat.as(:supplement)
      end

      # Errata
      rule(:errata) do
        (dash.maybe >> (str("errata") | str("err"))).as(:errata)
      end

      # Index
      rule(:index) do
        (str("index") | str("indx")).as(:index)
      end

      # Insert
      rule(:insert) do
        (str("insert") | str("ins")).as(:insert)
      end

      # Appendix
      rule(:appendix) do
        str("app").as(:appendix)
      end

      # Section
      rule(:section) do
        str("sec") >> digits.as(:section)
      end

      # Translation (3-letter language code)
      rule(:translation) do
        ((str("(") >> letter.repeat(3, 3).as(:translation) >> str(")")) |
          ((dot | space) >> letter.repeat(3, 3).as(:translation)))
      end

      # Draft stage
      rule(:draft) do
        space >> str("(Draft)").as(:draft)
      end

      # All possible parts (order matters!)
      rule(:parts) do
        (
          edition | revision | version | volume | part | update | addendum |
          supplement | errata | index | insert | section | appendix
        )
      end

      # Main identifier structure
      # Try compound series first (longest match), then publisher + simple series
      rule(:identifier) do
        (
          # Compound series (includes publisher in series name)
          compound_series >> (space | dot) >>
          report_number >> parts.repeat >> draft.maybe >> translation.maybe
        ) |
        (
          # Publisher + simple series
          publisher.maybe >> (space | dot).maybe >>
          simple_series >> (space | dot) >>
          report_number >> parts.repeat >> draft.maybe >> translation.maybe
        )
      end

      root(:identifier)
    end
  end
end