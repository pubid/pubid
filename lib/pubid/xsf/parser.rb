# frozen_string_literal: true

require "parslet"

module Pubid
  module Xsf
    # Parslet grammar for XSF identifiers. Two shapes: "XEP NNNN", and the two
    # named documents in SPECIAL_NUMBERS.
    class Parser < ::Pubid::Parser::Grammar
      # The XMPP extensions repository publishes two documents whose name is
      # not a number: the editor README and the `xep-xxxx` template. Both reach
      # pubid as real primary docids ("XEP README", "XEP xxxx"), so the number
      # rule admits these two literals beside the digits. Exact case, and no
      # other word: the flavor still rejects "XEP foo".
      SPECIAL_NUMBERS = %w[README xxxx].freeze

      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }

      rule(:special_number) do
        SPECIAL_NUMBERS.map { |name| str(name) }.reduce(:|)
      end

      # "XEP 0001" — publisher token, a single space, then the number kept as
      # a string of digits (leading zeros preserved by the builder), or the
      # name of one of the two named documents.
      rule(:identifier) do
        str("XEP") >> str(" ") >> (digits | special_number).as(:number)
      end

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
