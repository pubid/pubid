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
    # - urn:jis:WES 7700-1:2019 → WES 7700-1:2019 (the code carries its root)
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)
        code, year = parts
        text = code.to_s.start_with?("WES ") ? code.dup : "JIS #{code}"
        text += ":#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
