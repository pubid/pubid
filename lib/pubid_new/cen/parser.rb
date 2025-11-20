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

      # Publisher (can be combined like CEN/CLC)
      rule(:publisher) do
        (cwa | hd).as(:publisher) |
        (cen.as(:publisher) >> (slash >> clc.as(:copublisher)).maybe) |
        (clc.as(:publisher) >> (slash >> cen.as(:copublisher)).maybe) |
        en.as(:publisher)
      end

      # Stage (prEN, FprEN)
      rule(:stage) { (str("FprEN") | str("prEN")).as(:stage) }

      # Type
      rule(:type) { (str("Guide") | str("GUIDE") | str("TR") | str("TS")).as(:type) }

      # Number
      rule(:number) { digits.as(:number) }

      # Part (can be multi-level like 1-2 or 80-12)
      rule(:part) { dash >> match["0-9-"].repeat(1).as(:part) }
      rule(:parts) { part.repeat(0).as(:parts) }

      # Year
      rule(:year) { colon >> digit.repeat(4, 4).as(:year) }

      # Amendment (+A1:2008 or +A11:2020 or /A2:2019)
      rule(:amendment) do
        (plus.as(:amd_sep_plus) | slash.as(:amd_sep_slash)) >>
        str("A") >> digits.as(:amd_number) >>
        colon >> digit.repeat(4, 4).as(:amd_year)
      end

      # Corrigendum (+AC:2009 or +AC1:2008 or +AC2:2009)
      rule(:corrigendum) do
        plus >> str("AC") >> digits.maybe.as(:cor_number) >>
        colon >> digit.repeat(4, 4).as(:cor_year)
      end

      # Supplements (amendments and corrigenda)
      rule(:supplement) { (amendment | corrigendum).as(:supplement) }
      rule(:supplements) { supplement.repeat(0).as(:supplements) }

      # Edition (ED2, ED3, etc.)
      rule(:edition) { space >> str("ED") >> digits.as(:edition) }

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
        (stage | publisher) >>
        (space >> adopted_string).maybe >>
        (space >> type | slash >> type).maybe >>
        (space >> number >> parts >>
        year.maybe).maybe >>
        supplements >>
        edition.maybe
      end

      rule(:root) { identifier }

      def self.parse(input)
        # Normalize dash to slash in publisher combinations
        normalized = input.gsub("CEN-CLC", "CEN/CLC")
                          .gsub("CLC-CEN", "CLC/CEN")
                          .gsub("GUIDE", "Guide")
        new.parse(normalized)
      end
    end
  end
end