# frozen_string_literal: true

require "parslet"

module PubidNew
  module Ccsds
    class Parser < Parslet::Parser
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:alnum) { match["A-Za-z0-9"] }
      rule(:alnums) { alnum.repeat(1) }
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:dot) { str(".") }

      # CCSDS prefix
      rule(:ccsds_prefix) { str("CCSDS") >> space }

      # Number (can be alphanumeric like A02)
      rule(:number) { alnums.as(:number) }

      # Part (can be multi-digit like .21 or alphanumeric like .1)
      rule(:part) { dot >> alnums.as(:part) }

      # Type (all possible type letters)
      rule(:type) { dash >> match["A-Z"].as(:type) }

      # Edition (can have dots like 4.1)
      rule(:edition) { dash >> match["0-9."].repeat(1).as(:edition) }

      # Suffix (like -S)
      rule(:suffix) { dash >> match["A-Z"].as(:suffix) }

      # Corrigendum
      rule(:corrigendum) do
        space >> str("Cor.") >> space >> digits.as(:cor_number)
      end

      rule(:corrigenda) { corrigendum.repeat(0).as(:corrigenda) }

      # Trailing metadata (anything after " - ")
      rule(:metadata) do
        (space >> dash >> space >> any.repeat).ignore
      end

      # Main identifier
      rule(:identifier) do
        ccsds_prefix >>
          number >>
          part.maybe >>
          type.maybe >>
          edition.maybe >>
          suffix.maybe >>
          corrigenda >>
          metadata.maybe
      end

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end