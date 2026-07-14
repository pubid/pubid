# frozen_string_literal: true

require "parslet"

module Pubid
  module W3c
    # Parslet grammar for printed W3C identifiers, e.g.
    #   "W3C WD-charmod-19991129"   (type + code + date)
    #   "W3C NOTE-xml-names"        (type + code)
    #   "W3C 2dcontext"             (bare code)
    #
    # The grammar only splits off the leading maturity token; the code/date
    # boundary is resolved in the Builder, because a PEG `code` rule would
    # greedily consume the trailing date and make a `.maybe` date rule
    # unreliable. This is safe: no real W3C code ends in a same-width (4/6/8)
    # digit run, so the Builder's fixed-width trailing-date test never collides.
    class Parser < Parslet::Parser
      rule(:prefix) { str("W3C") >> str(" ") }

      # Known W3C maturity tokens. Order matters for shared prefixes: CRD before
      # CR, PER before PR, DNOTE before NOTE.
      rule(:type_token) do
        str("DNOTE") | str("NOTE") | str("WD") | str("CRD") | str("CR") |
          str("REC") | str("PER") | str("PR") | str("SPSD") | str("OBSL")
      end

      # A leading token is only a type when immediately followed by "-".
      rule(:type_part) { type_token.as(:type) >> str("-") }

      # The remainder: code plus an optional trailing date. Captured whole and
      # split in the Builder.
      rule(:rest) { any.repeat(1).as(:rest) }

      rule(:identifier) { prefix >> type_part.maybe >> rest }

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
