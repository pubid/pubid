# frozen_string_literal: true

require "parslet"

module Pubid
  module Ecma
    # Parslet grammar for ECMA identifiers.
    #
    # Four printed forms (see HANDOFFS/ecma.md):
    #   ECMA-411          standard
    #   ECMA-418-1        standard with part
    #   ECMA TR/101       technical report
    #   ECMA MEM/1970     memento
    #
    # Each branch captures its number under a distinct key so the builder can
    # pick the identifier class without a separate type token. Numbers are kept
    # as strings to preserve any leading zeros.
    class Parser < Parslet::Parser
      rule(:digits) { match["0-9"].repeat(1) }

      rule(:prefix) { str("ECMA") }

      rule(:tr) { str(" TR/") >> digits.as(:tr_number) }

      rule(:mem) { str(" MEM/") >> digits.as(:mem_number) }

      rule(:standard) do
        str("-") >> digits.as(:number) >>
          (str("-") >> digits.as(:part)).maybe
      end

      rule(:identifier) { prefix >> (tr | mem | standard) }

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
