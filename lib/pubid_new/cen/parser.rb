# frozen_string_literal: true

require "parslet"

module PubidNew
  module Cen
    class Parser < Parslet::Parser
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:slash) { str("/") }
      rule(:plus) { str("+") }
      rule(:colon) { str(":") }

      # Publishers
      rule(:en) { str("EN") }
      rule(:cen) { str("CEN") }
      rule(:clc) { str("CLC") }
      rule(:cwa) { str("CWA") }
      rule(:hd) { str("HD") }

      # Adopted organizations (ISO, IEC)
      rule(:iso) { str("ISO") }
      rule(:iec) { str("IEC") }
      rule(:cispr) { str("CISPR") }

      # Publisher (can be combined like EN/CLC or CEN/CLC)
      rule(:publisher) do
        (cwa | hd).as(:publisher) |
        (en.as(:publisher) >> (slash >> clc.as(:copublisher)).maybe) |
        (cen.as(:publisher) >> (slash >> clc.as(:copublisher)).maybe) |
        (clc.as(:publisher) >> (slash >> cen.as(:copublisher)).maybe) |
        en.as(:publisher)
      end

      # Stage prefixes captured as type_with_stage for proper lookup
      rule(:stage_prefix) { (str("FprEN") | str("prEN")).as(:type_with_stage) }

      # Type
      rule(:type) { (str("Guide") | str("GUIDE") | str("TR") | str("TS")).as(:type) }

      # Number
      rule(:number) { digits.as(:number) }

      # Part (can be multi-level like 1-2 or 80-12)
      rule(:part) { dash >> match["0-9-"].repeat(1).as(:part) }
      rule(:parts) { part.repeat(0).as(:parts) }

      # Year
      rule(:year) { colon >> digit.repeat(4, 4).as(:year) }

      # Month support for dates like 2016-11
      rule(:month_digits) do
        (
          str("01") | str("02") | str("03") | str("04") |
          str("05") | str("06") | str("07") | str("08") |
          str("09") | str("10") | str("11") | str("12")
        ).as(:month)
      end

      rule(:year_with_month) do
        colon >> digit.repeat(4, 4).as(:year) >> dash >> month_digits
      end

      rule(:date) { year_with_month | year }

      # Amendment (+A1:2008 or +A11:2020 or /A2:2019 or /A1 without year)
      rule(:amendment) do
        (plus.as(:amd_sep_plus) | slash.as(:amd_sep_slash)) >>
        str("A") >> digits.as(:amd_number) >>
        (colon >> digit.repeat(4, 4).as(:amd_year)).maybe
      end

      # Corrigendum (+AC:2009 or +AC1:2008 or +AC2:2009 or /AC1:2005 or /AC:2016-11 with month)
      rule(:corrigendum) do
        (plus.as(:amd_sep_plus) | slash.as(:amd_sep_slash)) >>
        str("AC") >> digits.maybe.as(:cor_number) >>
        (year_with_month | (colon >> digit.repeat(4, 4).as(:year))).maybe
      end

      # Supplements (amendments and corrigenda)
      rule(:supplement) { (amendment | corrigendum).as(:supplement) }
      rule(:supplements) { supplement.repeat(0).as(:supplements) }

      # Edition (ED2, ED3, etc.)
      rule(:edition) { space >> str("ED") >> digits.as(:edition) }

      # Fragment identifier (EN 60038 AMD1 FRAG2)
      rule(:fragment_identifier) do
        (stage_prefix | publisher) >>
        space >> number >> parts >>

        space >> str("AMD") >> digits.as(:amendment_number) >>

        space >> str("FRAG") >> digits.as(:fragment_number)
      end

      # Adopted standard as opaque string - must start with org name
      rule(:adopted_org_prefix) do
        str("ISO") | str("IEC") | str("CISPR")
      end

      rule(:adopted_string) do
        # Must start with organization name
        (adopted_org_prefix >> (supplement.absent? >> edition.absent? >> match("[^\n]")).repeat(0)).as(:adopted_string)
      end

      # Identifier
      rule(:identifier) do
        fragment_identifier |
        (stage_prefix | publisher) >>
        (space >> adopted_string).maybe >>
        (space >> type | slash >> type).maybe >>
        (space >> number >> parts >>
        year.maybe).maybe >>
        supplements >>
        edition.maybe
      end

      rule(:root) { identifier }

      def self.parse(input)
        # Normalize special dash characters
        normalized = input.gsub(/[\u2011\u00AD]/, "-")

        # Remove trailing hash symbols
        normalized = normalized.gsub(/#.*$/, "").strip

        # Filter out parenthetical notes (case-insensitive, multiple patterns)
        normalized = normalized.gsub(/\s*\([^)]*corrigendum[^)]*\)/i, "")

        # Normalize dash to slash in publisher combinations
        normalized = normalized.gsub("CEN-CLC", "CEN/CLC")
                           .gsub("CLC-CEN", "CLC/CEN")
                           .gsub("GUIDE", "Guide")
        new.parse(normalized)
      end
    end
  end
end