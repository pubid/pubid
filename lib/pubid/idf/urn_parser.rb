# frozen_string_literal: true

module Pubid
  module Idf
    # Parses IDF URNs back into identifiers.
    #
    # UrnGenerator emits: `urn:idf:{number}:{year}:` with a trailing empty
    # field (a known quirk of the generator).
    #
    # Examples:
    # - urn:idf:87:2019: → IDF 87:2019
    # - urn:idf:100:     → IDF 100
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body).reject(&:empty?)

        number, year = parts
        text = "IDF #{number}"
        text += ":#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
