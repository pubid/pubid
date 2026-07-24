# frozen_string_literal: true

require "parslet"

module Pubid
  module Isbn
    # Parslet grammar for ISBN identifiers per ISO 2108.
    #
    # Accepts:
    #   [ISBN[ |:]] {10 or 13 digits with optional hyphens}
    #
    # ISBN-10 final digit may be "X" (check digit value 10). Hyphens are
    # optional and may appear in any group position; they are preserved
    # for round-trip rendering.
    class Parser < Parslet::Parser
      rule(:space)   { str(" ") }
      rule(:colon)   { str(":") }
      rule(:hyphen)  { str("-") }
      rule(:digit)   { match("[0-9]") }
      rule(:x_digit) { digit | str("X") }

      rule(:isbn_prefix) do
        (str("ISBN") >> (space | (space.maybe >> colon >> space.maybe))).maybe
      end

      rule(:digit_group) { digit.repeat(1) }
      rule(:x_group)     { x_digit.repeat(1) }

      # Loose "ISBN-ish" token: digits or final X, separated by hyphens.
      rule(:isbn_body) do
        (digit_group >> (hyphen >> digit_group).repeat >>
          (hyphen >> x_digit).maybe).as(:body) |
          (digit.repeat(9, 12) >> x_digit.maybe).as(:body)
      end

      rule(:identifier) { isbn_prefix >> isbn_body }

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
