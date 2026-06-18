# frozen_string_literal: true

module Pubid
  module Jis
    # Parses JIS URNs back into identifiers.
    #
    # UrnGenerator emits: `urn:jis:{code}:{year}` where code is the
    # classification letter + number (e.g., "X 0201").
    #
    # Examples:
    # - urn:jis:X 0201:1997 → JIS X 0201:1997
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)
        code, year = parts
        text = "JIS #{code}"
        text += ":#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
