# frozen_string_literal: true

module Pubid
  module Ccsds
    # Parses CCSDS URNs back into identifiers.
    #
    # UrnGenerator emits: `urn:ccsds:{code}` where the code is the full
    # identifier suffix after "CCSDS " (e.g., "120.0-G-4").
    #
    # Examples:
    # - urn:ccsds:120.0-G-4  → CCSDS 120.0-G-4
    # - urn:ccsds:100.0-G-1-S → CCSDS 100.0-G-1-S
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        flavor_parse("CCSDS #{body}")
      end
    end
  end
end
