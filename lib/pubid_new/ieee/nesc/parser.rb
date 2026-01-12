# frozen_string_literal: true

require "parslet"

module PubidNew
  module Ieee
    module Nesc
      # Parser for National Electrical Safety Code (NESC) identifiers
      #
      # Handles multiple NESC identifier formats including:
      # - Standard C2-YYYY format
      # - Year-first YYYY NESC format
      # - Draft format
      # - Handbook and Redline variations
      #
      # @example Parse C2 standard
      #   parser = Parser.new
      #   result = parser.parse("C2-1997 National Electric Safety Code")
      #
      # @example Parse handbook
      #   parser = Parser.new
      #   result = parser.parse("2017 NESC Handbook, Premier Edition")
      class Parser < Parslet::Parser
        root(:nesc_identifier)

        rule(:space) { str(" ") }
        rule(:comma) { str(",") }
        rule(:digit) { match("[0-9]") }
        rule(:year) { digit.repeat(4, 4) }
        rule(:dash) { str("-") }

        # C2 code designation
        rule(:c2_code) do
          str("C2").as(:code)
        end

        # NESC name variations
        rule(:nesc_full_name) do
          str("National Electrical Safety Code(R)") |
            str("National Electrical Safety Code") |
            str("National Electric Safety Code") # Typo variation
        end

        rule(:nesc_abbr) do
          str("NESC(R)") | str("NESC")
        end

        rule(:nesc_name) do
          nesc_full_name | nesc_abbr
        end

        # Registered trademark notation
        rule(:registered) do
          str("(R)").maybe
        end

        # Edition notations
        rule(:edition) do
          (
            str("Premier Edition") |
            str("First Edition") |
            str("Second Edition") |
            str("Third Edition") |
            str("Fourth Edition") |
            str("Fifth Edition") |
            str("Sixth Edition") |
            str("Seventh Edition") |
            str("Eighth Edition") |
            str("Ninth Edition") |
            str("Tenth Edition")
          ).as(:edition)
        end

        # Variant types (Handbook, Redline)
        rule(:variant) do
          (
            str("Handbook") |
            str("Redline")
          ).as(:variant)
        end

        # Month names for drafts
        rule(:month) do
          (
            str("January") | str("February") | str("March") |
            str("April") | str("May") | str("June") |
            str("July") | str("August") | str("September") |
            str("October") | str("November") | str("December")
          ).as(:month)
        end

        # Pattern 1: C2-YYYY Standard format
        # Examples: "C2-1997 National Electric Safety Code (NESC)"
        #           "C2-2012 National Electrical Safety Code"
        rule(:c2_standard) do
          c2_code >>
            dash >>
            year.as(:year) >>
            (comma.maybe >> space).maybe >>
            nesc_full_name >>
            (space >> str("(") >> nesc_abbr >> str(")")).maybe
        end

        # Pattern 2: YYYY NESC format (year-first)
        # Examples: "2017 NESC(R) Handbook, Premier Edition"
        #           "2017 National Electrical Safety Code(R) (NESC(R))"
        #           "2012 NESC Handbook"
        rule(:year_first) do
          year.as(:year) >>
            space >>
            (
              # Full name with optional (NESC) suffix
              (nesc_full_name >> registered >>
               (space >> str("(") >> nesc_abbr >> registered >> str(")")).maybe) |
              # Just NESC abbreviation
              (nesc_abbr >> registered)
            ) >>
            (space >> variant).maybe >>
            (comma >> space >> edition).maybe
        end

        # Pattern 3: Draft format
        # Examples: "Draft National Electrical Safety Code, January 2016"
        #           "Draft NESC, June 2011"
        rule(:draft_nesc) do
          str("Draft").as(:draft) >>
            space >>
            nesc_name >>
            comma >> space >>
            month >> space >> year.as(:year)
        end

        # Main identifier rule - try patterns in order
        # Put most specific patterns first
        rule(:nesc_identifier) do
          draft_nesc | c2_standard | year_first
        end
      end
    end
  end
end
