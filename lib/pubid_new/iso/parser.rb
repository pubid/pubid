# frozen_string_literal: true

require "parslet"

module PubidNew
  module Iso
    class Parser < Parslet::Parser
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match["A-Z"] }
      rule(:alnum) { match["A-Z0-9"] }
      rule(:alnums) { alnum.repeat(1) }
      rule(:space) { str(" ") }
      rule(:dash) { str("-") | str("‑") | str("‐") }
      rule(:slash) { str("/") }

      # Publishers
      rule(:iso) { str("ISO") }
      rule(:iec) { str("IEC") }
      rule(:ieee) { str("IEEE") }
      rule(:sae) { str("SAE") }
      rule(:astm) { str("ASTM") }
      rule(:cie) { str("CIE") }
      rule(:hl7) { str("HL7") }
      rule(:oecd) { str("OECD") }

      # Publisher with copublishers
      rule(:publisher) do
        iso.as(:publisher) >>
        (slash >> (iec | ieee | sae | astm | cie | hl7 | oecd).as(:copublisher)).repeat(0, 3)
      end

      # Type (including legacy R for Recommendation, TTA for Technology Trends Assessment)
      rule(:type) do
        (str("Guide") | str("GUIDE") | str("ISP") | str("IWA") | str("TTA") |
         str("TR") | str("TS") | str("PAS") | str("R")).as(:type)
      end

      # Stage
      rule(:stage) do
        (str("PRF") | str("NWIP") | str("WD") | str("CD") | str("AWI") | str("NP") | str("PWI")).as(:stage)
      end

      # Typed stages (combined stage+type)
      rule(:typed_stage) do
        (str("DTR") | str("DTS") | str("DIS") | str("FDIS") | str("FDTR") | str("FDTS")).as(:typed_stage)
      end

      # Number
      rule(:number) { digits.as(:number) }

      # Part (can be alphanumeric like A01, B02, or just digits)
      rule(:part) { dash >> alnums.as(:part) }
      rule(:parts) { part.repeat(0).as(:parts) }

      # Edition (can be "Ed 3", "Ed.2", "ED1")
      rule(:edition) do
        (space >> (str("Ed.") | str("Ed ") | str("Ed")) >> space.maybe >> digits.maybe |
         space >> str("ED") >> digits).as(:edition)
      end

      # Year
      rule(:year) { str(":") >> space.maybe >> digit.repeat(4, 4).as(:year) }

      # Iteration
      rule(:iteration) { str(".") >> digits.as(:iteration) }

      # Language
      rule(:language) do
        str("(") >> match["a-zA-Z"].repeat(1).as(:language) >> str(")")
      end

      # Basic identifier
      rule(:identifier) do
        publisher >>
        # Typed stage or regular stage
        ((slash | space) >> (typed_stage | stage)).maybe >>
        # Type comes after space or slash
        ((space | slash) >> type).maybe >>
        space >> number >> parts >>
        iteration.maybe >>
        year.maybe >>
        edition.maybe >>
        language.maybe
      end

      rule(:root) { identifier }

      def self.parse(input)
        # Normalize whitespace around colons
        normalized = input.gsub(/\s+:/, ':')
        new.parse(normalized)
      end
    end
  end
end
