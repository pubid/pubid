# frozen_string_literal: true

require "parslet"

module Pubid
  module Xsf
    # Parslet grammar for XSF identifiers. One fixed shape: "XEP NNNN".
    class Parser < Parslet::Parser
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }

      # "XEP 0001" — publisher token, a single space, then the number kept as
      # a string of digits (leading zeros preserved by the builder).
      rule(:identifier) do
        str("XEP") >> str(" ") >> digits.as(:number)
      end

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
