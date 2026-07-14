# frozen_string_literal: true

module Pubid
  module Ogc
    # Parses OGC URNs back into identifiers.
    #
    # UrnGenerator emits: `urn:ogc:<year>:<number>[:<revision>]`.
    #
    # Examples:
    # - urn:ogc:25:023    → 25-023
    # - urn:ogc:24:032:r1 → 24-032r1
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        year, number, revision = split_parts(body)
        text = "#{year}-#{number}"
        text += revision.to_s if revision
        flavor_parse(text)
      end
    end
  end
end
