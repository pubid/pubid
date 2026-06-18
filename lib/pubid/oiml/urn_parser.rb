# frozen_string_literal: true

module Pubid
  module Oiml
    # Parses OIML URNs back into identifiers.
    #
    # UrnGenerator emits: `urn:oiml:{type}:{number}[-{part}]` where type
    # is the lowercase document class (r for Recommendation, d for Document).
    #
    # Examples:
    # - urn:oiml:r:111-1 → OIML R 111-1
    # - urn:oiml:d:1     → OIML D 1
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)
        type_token, number = parts
        flavor_parse("OIML #{type_token.upcase} #{number}")
      end
    end
  end
end
