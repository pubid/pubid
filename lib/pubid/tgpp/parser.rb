# frozen_string_literal: true

require "parslet"

module Pubid
  module Tgpp
    # Parslet grammar for 3GPP identifiers.
    #
    # Form: `[3GPP ]<TR|TS> <NN.NNN>[suffix][-part…]:<release>/<version>`
    #   TS 23.207:REL-4/2.0.0
    #   3GPP TR 00.01U:UMTS/3.0.0
    #   TS 29.198-04-1:REL-5/5.0.0
    #   TS 02.68:Release 2000/9.0.0
    class Parser < Parslet::Parser
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:space) { str(" ") }

      # Optional leading publisher token.
      rule(:publisher_prefix) { str("3GPP") >> space }

      # Document type.
      rule(:type) { (str("TR") | str("TS")).as(:type) }

      # Dotted number core, kept as a string (preserves leading zeros).
      rule(:number_core) { (digits >> str(".") >> digits).as(:number) }

      # Letter suffix directly after the number ("U"/"dcs"/"ext"…). Generic so
      # future controlled-vocabulary values keep round-tripping.
      rule(:suffix) { match["A-Za-z"].repeat(1).as(:suffix) }

      # Hyphen parts.
      rule(:part) { str("-") >> digits.as(:part) }
      rule(:parts) { part.repeat(0).as(:parts) }

      # Release token, stored verbatim: everything up to the version separator.
      # Excludes ":" (as well as "/") so the ":"-delimited URN scheme can always
      # encode it — every real release ("REL-4", "Ph1", "UMTS", "Release 2000")
      # is colon-free.
      rule(:release) { match["^/:"].repeat(1).as(:release) }

      # Three-part version, kept as a string.
      rule(:version) do
        (digits >> str(".") >> digits >> str(".") >> digits).as(:version)
      end

      rule(:identifier) do
        publisher_prefix.maybe >>
          type >> space >>
          number_core >> suffix.maybe >> parts >>
          (str(":") >> release).maybe >>
          str("/") >> version
      end

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
