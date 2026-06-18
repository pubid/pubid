# frozen_string_literal: true

module Pubid
  module Jcgm
    # Parses JCGM URNs back into identifiers.
    #
    # UrnGenerator emits: `urn:jcgm:{number}:{year}`.
    #
    # Examples:
    # - urn:jcgm:200:2012 → JCGM 200:2012
    # - urn:jcgm:100:2008 → JCGM 100:2008
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)
        number, year = parts
        text = "JCGM #{number}"
        text += ":#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
