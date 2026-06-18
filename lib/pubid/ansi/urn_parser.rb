# frozen_string_literal: true

module Pubid
  module Ansi
    # Parses ANSI URNs back into identifiers.
    #
    # UrnGenerator emits: `urn:ansi:{code}:{year}` where the code carries
    # the alpha-numeric designation (e.g., "X3.4").
    #
    # Examples:
    # - urn:ansi:X3.4:1963 → ANSI X3.4:1963
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)
        code, year = parts
        text = "ANSI #{code}"
        text += ":#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
