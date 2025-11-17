# frozen_string_literal: true

require "parslet"

module PubidNew
  module Ieee
    # Parser class for IEEE identifiers
    # Single Responsibility: Parsing IEEE identifier syntax
    # Note: IEEE is extremely complex with many edge cases
    class Parser < Parslet::Parser
      # Basic building blocks
      rule(:space) { str(" ") }
      rule(:space?) { space.maybe }
      rule(:dash) { str("-") }
      rule(:dash?) { dash.maybe }
      rule(:dot) { str(".") }
      rule(:slash) { str("/") }
      rule(:comma) { str(", ") }
      rule(:digit) { match("[0-9]") }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match("[A-Za-z]") }
      rule(:upper) { match("[A-Z]") }
      rule(:lower) { match("[a-z]") }

      # Year pattern (4 digits starting with 19 or 20)
      rule(:year_digits) do
        (str("19") | str("20")) >> digit.repeat(2, 2) >> digits.absent?
      end

      # Month patterns
      rule(:month_name) do
        str("January") | str("February") | str("March") | str("April") |
        str("May") | str("June") | str("July") | str("August") |
        str("September") | str("October") | str("November") | str("December") |
        str("Jan") | str("Feb") | str("Mar") | str("Apr") | str("Jun") |
        str("Jul") | str("Aug") | str("Sep") | str("Oct") | str("Nov") | str("Dec")
      end

      # Organizations
      rule(:organization) do
        str("IEEE") | str("AIEE") | str("ANSI") | str("ASA") |
        str("IEC") | str("ISO") | str("ASTM") | str("NACE") |
        str("NSF") | str("ASHRAE") | str(" NCTA")
      end

      rule(:publisher) do
        organization.as(:publisher)
      end

      rule(:copublisher) do
        (slash >> space? >> organization).as(:copublisher)
      end

      # Document number
      rule(:number) do
        (str("P").maybe >> (digits | upper).repeat(1) >> lower.maybe).as(:number)
      end

      # Type - handle "No." and "No" (case-insensitive), longest first
      rule(:type_word) do
        str("Std") | str("STD") | str("Standard") |
        match("[Nn]") >> str("o.") | match("[Nn]") >> str("o")
      end

      # Part and subpart
      rule(:part) do
        (dot | dash) >> (match("[0-9A-Za-z]").repeat(1)).as(:part)
      end

      rule(:subpart) do
        (dot | dash | str("_")) >> 
        ((str("REV") | str("Rev")).maybe >> match("[0-9a-z]").repeat(1) >> 
         (dot >> digits).maybe).as(:subpart)
      end

      # Year component
      rule(:year) do
        (dot | dash) >> year_digits.as(:year) >> str("(E)").maybe
      end

      # Draft patterns
      rule(:draft_status) do
        (str("Active Unapproved") | str("Unapproved") | str("Approved")) >> space
      end

      rule(:draft_prefix) do
        space? >> (str("/") | str("_") | dash | space)
      end

      rule(:draft_version) do
        # D1, D2, DD3, D3Q, D2009-d, etc.
        str("D") >> str("IS").absent? >> str("-").maybe >> 
        (match("[0-9A-Za-z]").repeat(1) >> str("-d").maybe).as(:draft_version)
      end

      rule(:draft_date) do
        ((space? >> comma >> space? | space) >> month_name.as(:month)).maybe >>
        (
          ((space >> digits.as(:day)).maybe >> comma >> year_digits.as(:year)) |
          (comma >> space? >> year_digits.as(:year))
        )
      end

      rule(:draft) do
        (draft_prefix >> draft_version.repeat(1, 2) >> 
         (dot >> digits.as(:revision)).maybe >>
         draft_date.maybe).as(:draft)
      end

      # Edition
      rule(:edition) do
        (comma >> year_digits.as(:year) >> str(" Edition")) |
        ((space | dash) >> str("Edition ") >> 
         (digits >> dot >> digits).as(:edition) >> 
         (space | str(" - ")) >> year_digits.as(:year))
      end

      # Part/subpart/year combinations
      rule(:part_subpart_year) do
        (part >> subpart.repeat(1, 2) >> year) |
        (part >> subpart >> year) |
        (part >> year) |
        (part >> subpart) |
        year |
        part
      end

      # Corrigendum
      rule(:corrigendum) do
        ((str("_") | slash | dash) >> str("Cor") >> (dash | dot.maybe >> space?) >>
         digits.as(:cor_number) >> 
         ((dash | str(":")) >> year_digits.as(:cor_year)).maybe).as(:corrigendum)
      end

      # Amendment
      rule(:amendment) do
        (slash >> str("Amd") >> digits.as(:amd_number) >> 
         (dash >> year_digits.as(:amd_year)).maybe).as(:amendment)
      end

      # Reaffirmed
      rule(:reaffirmed) do
        (str("Reaffirmed ") >> year_digits.as(:year)).as(:reaffirmed)
      end

      # Redline
      rule(:redline) do
        str(" - Redline").as(:redline)
      end

      # Additional parameters (inside parentheses)
      rule(:additional_parameters) do
        (space? >> str("(") >> 
         (reaffirmed | 
          str("Revision of IEEE Std ") >> match("[^)]").repeat(1).as(:revision_of) |
          str("Amendment to IEEE Std ") >> match("[^)]").repeat(1).as(:amendment_to) |
          str("Adoption of ") >> match("[^)]").repeat(1).as(:adoption) |
          match("[^)]").repeat(1).as(:note)
         ) >>
         str(")").maybe).as(:parameters)
      end

      # Basic IEEE identifier (no dual PubIDs or complex revisions yet)
      rule(:identifier) do
        (publisher >> (copublisher.repeat).as(:copublishers)).as(:publishers) >>
        space >> (draft_status.as(:draft_status)).maybe >>
        (str("Draft ").maybe >> type_word.as(:type) >> space?).maybe >>
        number >>
        (part_subpart_year | edition).maybe >>
        corrigendum.maybe >>
        amendment.maybe >>
        draft.maybe >>
        (comma >> month_name.as(:month) >> space >> year_digits.as(:year)).maybe >>
        edition.maybe >>
        additional_parameters.maybe >>
        redline.maybe
      end

      root(:identifier)
    end
  end
end