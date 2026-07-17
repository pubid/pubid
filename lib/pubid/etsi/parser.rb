# frozen_string_literal: true

require "parslet"

module Pubid
  module Etsi
    class Parser < Parslet::Parser
      # Basic elements
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match["A-Za-z"] }
      rule(:alnum) { match["A-Za-z0-9"] }
      rule(:letters) { letter.repeat(1) }
      rule(:alnums) { alnum.repeat(1) }
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:dot) { str(".") }

      # ETSI prefix
      rule(:etsi_prefix) { str("ETSI") >> space }

      # Type prefixes - all 15 types
      rule(:type) do
        (str("I-ETS") | str("TCRTR") | str("GTS") | str("ETR") |
         str("ETS") | str("TBR") | str("NET") | str("EN") |
         str("ES") | str("EG") | str("TS") | str("GR") |
         str("GS") | str("SR") | str("TR")).as(:type)
      end

      # Number variants

      # GSM with dotted number: "GSM 11.14", "GSM 02.01"
      rule(:gsm_with_space_number) do
        str("GSM").capture(:gsm_prefix) >> space >>
          digits.capture(:main) >> dot >> digits.capture(:sub)
      end

      # Number with dot: 11.40, 02.01
      rule(:dotted_number) do
        digits.capture(:main) >> dot >> digits.capture(:sub)
      end

      # Complex format: ABC 123 or ABC-DEF 123 or IP6 031
      rule(:complex_number) do
        alnums.capture(:prefix1) >>
          (dash >> alnums.capture(:prefix2)).maybe >>
          space >>
          digits.capture(:num)
      end

      # Simple format: just digits
      rule(:simple_number) do
        digits.capture(:num)
      end

      # Main number
      rule(:number) do
        (gsm_with_space_number | dotted_number | complex_number | simple_number).as(:number)
      end

      # Optional minor part
      rule(:minor) do
        space >> digits.as(:minor)
      end

      # Parts
      rule(:part) do
        dash >> alnums.as(:part)
      end

      rule(:parts) { part.repeat(0).as(:parts) }

      # Version
      rule(:version) do
        str("V") >> match["0-9."].repeat(1).as(:version)
      end

      # Edition
      rule(:edition) do
        str("ed.") >> digits.as(:edition)
      end

      # Version or edition
      rule(:version_or_edition) do
        version | edition
      end

      # Published date
      rule(:date_part) do
        str("(") >>
          digit.repeat(4, 4).as(:year) >>
          dash >>
          digit.repeat(2, 2).as(:month) >>
          str(")")
      end

      # Individual supplements
      rule(:amendment) do
        str("/A") >> digits.as(:number)
      end

      rule(:corrigendum) do
        str("/C") >> digits.as(:number)
      end

      # Single supplement (AMD or COR)
      rule(:single_supplement) do
        amendment.as(:amendment) | corrigendum.as(:corrigendum)
      end

      # Multiple supplements
      rule(:supplements) do
        single_supplement.repeat(1).as(:supplements)
      end

      # Main identifier
      #
      # The mandatory core is `etsi_prefix type number` (+ optional
      # minor/parts/supplements), mirroring ISO. The version/edition and date
      # suffixes are optional so a partial reference (e.g. "ETSI GS ZSM 012")
      # parses with version/date left nil. Each `.maybe` guards its own leading
      # space so no trailing space is demanded when the suffix is absent.
      rule(:identifier) do
        etsi_prefix >>
          type >> space >>
          number >> minor.maybe >> parts >>
          supplements.maybe >>
          (space >> version_or_edition).maybe >>
          (space >> date_part).maybe
      end

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
