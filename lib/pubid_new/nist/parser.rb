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

      # Hash prefix for machine-readable formats
      rule(:hash_prefix) { str("#") }

      # Month abbreviations
      rule(:month_abbrev) do
        str("January") | str("February") | str("March") | str("April") |
        str("May") | str("June") | str("July") | str("August") |
        str("September") | str("October") | str("November") | str("December") |
        str("Jan") | str("Feb") | str("Mar") | str("Apr") |
        str("Jun") | str("Jul") | str("Aug") | str("Sep") | str("Oct") | str("Nov") | str("Dec")
      end

      # Publisher
      rule(:publisher) do
        (str("NBS") | str("NIST")).as(:publisher)
      end

      # Compound series (include publisher in series name) - must be checked FIRST
      rule(:compound_series) do
        (
          # Longest patterns first to avoid partial matches
          str("NBS BRPD-CRPL-D") | str("NBS CRPL-F-A") | str("NBS CRPL-F-B") |
          str("NBS CS-E") | str("CSRC Building Block") | str("CSRC Use Case") | str("CSRC Book") |
          str("ITL Bulletin") | str("NIST LC") | str("NIST PS") | str("NIST DCI") | str("NIST Other") |
          str("NSRDS-NBS") |
          # NBS specific patterns that conflict with simple series (shorter ones)
          str("NBS CSM") | str("NBS CIRC") | str("NBS CRPL") | str("NBS CS") |
          str("NBS CIS") | str("NBS HR") | str("NBS IRPL") | str("NBS IP") | str("NBS LC") | str("NBS PS") |
          str("NBS BH")
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

      # Number patterns - allow letters and digits, including edition patterns like "e2"
      # Suffix letter only if NOT followed by digit (prevents consuming 'e2', 'r1', etc.)
      # AND not followed by special keywords like 'sec', 'index', 'insert', 'errata'
      rule(:number_suffix) do
        match("[a-zA-Z]") >>
        (str("ec") | str("ndex") | str("nsert") | str("rrata") | str("pp")).absent? >>
        digits.maybe
      end

      rule(:digits_with_suffix) do
        digits >>
          # Suffix only if not followed by digit (e.g., don't match 'e' in '140e2')
          (number_suffix >> digit.absent?).maybe
      end

      # Report number - first part - support edition prefixes like "e104" and supplement suffixes like "144supp"
      # Supplements should be handled as separate parts
      rule(:first_number) do
        (
          # Regular number with eN suffix and optional supplement (e.g., "101e2supp") - most specific
          (digits >> str("e") >> digits >> str("supp") >> digits.maybe) |
          # Edition prefix followed by digits and optional supplement with digits
          (str("e") >> digits >> str("supp") >> digits.maybe) |
          # Regular number with eN suffix (e.g., "101e2")
          (digits >> str("e") >> digits) |
          # Edition prefix followed by digits (e.g., "e104") - but NOT if followed by dash+digits (that's edition+year)
          (str("e") >> digits >> (dash >> digits).absent?) |
          # Letter prefix with digits (e.g., "c4" for CRPL)
          (lower_letter >> digits) |
          # Regular number with supplement suffix with month/year (e.g., "24suppJan1924")
          (digits >> str("supp") >> month_abbrev >> digits) |
          # Regular number with supplement suffix (e.g., "144supp") - with optional digits
          (digits >> str("supp") >> digits.maybe) |
          # Regular number with supplement suffix followed by month/year for date range
          (digits >> str("sup") >> month_abbrev >> digits) |
          # Regular number with optional suffix (original) - includes letters like "A"
          digits_with_suffix
        ).as(:first_number)
      end

      # Second number (after dash) - allow pt suffix, letter suffixes, and CRPL patterns
      rule(:second_number) do
        (
          # CRPL range with underscore (e.g., "2_3-1A")
          (digits >> str("_") >> digits >> dash >> digits >> upper_letter.maybe) |
          # Letter followed by dash and digits (e.g., "m-5")
          (lower_letter >> dash >> digits) |
          # Number with pt suffix (e.g., "57pt1")
          (digits >> str("pt") >> digits) |
          # Special patterns like "NCNR", "PERMIS", "BFRL"
          str("NCNR") | str("PERMIS") | str("BFRL") |
          # Regular number with optional suffix
          digits_with_suffix
        ).as(:second_number)
      end

      # Edition with different formats
      rule(:edition) do
        (
          # Edition with revision and date: e2revJune1908, e3revJan1925
          ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >>
           str("rev") >> match("[A-Za-z]").repeat(3, 9).as(:edition_month) >> digits.as(:edition_year)) |
          # Edition with year and month: e201801, e2018 (4-digit year)
          (str("e") >> match("[0-9]").repeat(4, 4).as(:edition_year) >> match("[0-9]").repeat(2, 2).as(:edition_month).maybe) |
          # Edition number with dash and year: e2-1915, e3-2020
          ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >> dash >> digits.as(:edition_year)) |
          # Edition with dash and year/month: -2018, -Jan2018, -June1908, -April1909
          (dash >> (
            (match("[A-Za-z]").repeat(3, 9).as(:edition_month) >> digits.as(:edition_year)) |
            digits.as(:edition_year) |
            (match("[A-Za-z]").repeat(3, 3).as(:edition_month) >> match("[0-9]").repeat(2, 2).as(:edition_day) >>
              slash >> digits.as(:edition_year))
          )) |
          # Edition with e prefix and revision suffix: e2rev (edition 2 with revision)
          ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >> str("rev").as(:edition_has_rev).maybe) |
          # Edition with e prefix: e2, e3 (1-3 digits, NOT 4)
          ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition)) |
          # Revision-based edition: revJune1908, revJan1925
          (str("rev") >> match("[A-Za-z]").repeat(3, 9).as(:edition_month) >> digits.as(:edition_year))
        )
      end

      # CRPL range pattern (e.g., 1-2_3-1) - matches after first dash
      rule(:crpl_range) do
        (digits >> str("_") >> digits >> dash >> digits).as(:crpl_range)
      end

      # Full report number - support CRPL ranges
      rule(:report_number) do
        first_number >> (dash >> (crpl_range | second_number)).maybe
      end

      # Volume
      rule(:volume) do
        (str("v") | str(" Vol. ")) >> (digits >> (str("a-l") | str("m-z")).maybe >> upper_letter.repeat).as(:volume)
      end

      # Part - enhanced to support patterns like p1adde1 (part 1 addition edition 1)
      rule(:part) do
        (str("pt") | str("p") | str("P") | str(" Part ")) >>
          (digits >>
           (str("add") >> (str("e") >> digits).maybe).maybe >>
           (dash >> digits).maybe).as(:part)
      end

      # Revision
      rule(:revision) do
        ((str(" rev ") | str("rev") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
          (digits >> lower_letter.maybe).maybe).as(:revision)
      end

      # Version - enhanced for dot-separated versions
      rule(:version) do
        ((str("ver") | str(" Ver. ") | str(" Version ") | str("v")) >>
          (digits >> (dot >> digits).repeat).maybe).as(:version)
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

      # Supplement - enhanced to support date patterns, year patterns, and combined with revision
      # Examples: suppJan1924, supp3/1926, supp1925, supJun1925-Jun1927 (date ranges), supprev
      rule(:supplement) do
        (str("supp") | str("sup")) >>
        (
          # Supplement followed by revision: supprev
          (str("rev")).as(:supplement_with_rev) |
          # Date range pattern: Jan1924-Jan1926
          (month_abbrev.as(:supp_month_start) >> digits.as(:supp_year_start) >>
           dash >> month_abbrev.as(:supp_month_end) >> digits.as(:supp_year_end)).as(:supplement_date_range) |
          # Month and year: Jan1924
          (month_abbrev.as(:supp_month) >> digits.as(:supp_year)).as(:supplement_date) |
          # Number with slash and year: 3/1926
          (digits.as(:supp_number) >> slash >> digits.as(:supp_year)).as(:supplement_slash_year) |
          # Just year: 1925
          digits.as(:supp_year) |
          # General suffix (other patterns)
          match("[A-Za-z0-9]").repeat(1).as(:supplement_suffix)
        ).maybe
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

      # Section - make digits optional for patterns like just "sec"
      rule(:section) do
        str("sec") >> digits.as(:section).maybe
      end

      # Translation (3-letter language code)
      rule(:translation) do
        ((str("(") >> letter.repeat(3, 3).as(:translation) >> str(")")) |
          ((dot | space) >> letter.repeat(3, 3).as(:translation)))
      end

      # Draft stage - enhanced to support suffix pattern
      rule(:draft) do
        (space >> str("(Draft)") | dash >> str("draft")).as(:draft)
      end

      # All possible parts (order matters!)
      rule(:parts) do
        (
          # Put more specific patterns first
          section | index | insert | appendix |
          edition | revision | version | volume | part | update | addendum |
          supplement | errata
        )
      end

      # Dot-separated machine-readable format: NIST.SP.800-116 or #NIST.2024-01-15.123
      rule(:mr_identifier) do
        hash_prefix.maybe >>
        publisher >> dot >>
        simple_series >> dot >>
        report_number >>
        (dash >> str("upd") >> digits.maybe).maybe >>
        parts.repeat >> draft.maybe
      end

      # Main identifier structure
      # Try compound series first (longest match), then publisher + simple series
      rule(:identifier) do
        mr_identifier |
        (
          # Compound series (includes publisher in series name)
          compound_series >> (space | dot) >>
          report_number.maybe >> parts.repeat >> draft.maybe >> translation.maybe
        ) |
        (
          # Publisher + simple series - require space/dot between publisher and series
          publisher >> (space | dot) >>
          simple_series >> (space | dot) >>
          report_number.maybe >> parts.repeat >> draft.maybe >> translation.maybe
        ) |
        (
          # Simple series only (no publisher)
          simple_series >> (space | dot) >>
          report_number.maybe >> parts.repeat >> draft.maybe >> translation.maybe
        )
      end

      root(:identifier)
    end
  end
end