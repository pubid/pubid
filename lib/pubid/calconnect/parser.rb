# frozen_string_literal: true

require "parslet"

module Pubid
  module Calconnect
    # Parslet grammar for CalConnect identifiers.
    #
    # Shape: CC[/<series>] <number>:<date>
    #   CC 18011:2018
    #   CC/DIR 10006:2019
    #   CC/Adv 0707.1:2007        (dot sub-part)
    #   CC/A 0812-1:2008          (dash sub-part)
    #   CC/WD 51017:2024-07-23    (full ISO date)
    class Parser < Parslet::Parser
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }

      # Publisher token
      rule(:publisher) { str("CC") }

      # Series token — an open [A-Za-z]+ set (A, WD, R, S, CD, DIR, Adv, FDS, …)
      rule(:series) { match["A-Za-z"].repeat(1).as(:series) }

      # Number — digits, preserving leading zeros, with at most one dot- or
      # dash-delimited sub-part ("0707.1", "0812-1"). Kept as a string.
      rule(:number) do
        (digits >> ((str(".") | str("-")) >> digits).maybe).as(:number)
      end

      # Date after the colon: a year, optionally a full "YYYY-MM-DD". The colon
      # hard-delimits number from date, and month+day only appear together, so
      # the split is unambiguous.
      rule(:date) do
        digits.as(:year) >>
          (str("-") >> digits.as(:month) >> str("-") >> digits.as(:day)).maybe
      end

      rule(:identifier) do
        publisher >>
          (str("/") >> series).maybe >>
          str(" ") >>
          number >>
          str(":") >>
          date
      end

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
