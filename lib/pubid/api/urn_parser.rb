# frozen_string_literal: true

module Pubid
  module Api
    # Parses API URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:api:{publisher}:{number}[-{part}]:{year}
    # where slot[1] is the publisher (default "api"), slot[2] is the number
    # with optional `-part` suffix, slot[3] is the optional year.
    #
    # Examples:
    # - urn:api:api:1104              → API STD 1104
    # - urn:api:api:1104-1:2020       → API STD 1104-1:2020
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        _type, number = parts
        idx = 2
        part = nil
        if parts[idx]&.start_with?("-")
          part = parts[idx]
          idx += 1
        end
        year = parts[idx]

        text = "API STD #{number}#{part}"
        text += ":#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
