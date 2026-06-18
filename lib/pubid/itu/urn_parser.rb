# frozen_string_literal: true

module Pubid
  module Itu
    # Parses ITU URNs back into identifiers.
    #
    # UrnGenerator emits: `urn:itu:{sector}:{code}` where sector is the
    # lowercase ITU sector letter (t for ITU-T, r for ITU-R, d for ITU-D)
    # and code is the document code (e.g., "BO.1073-1").
    #
    # Examples:
    # - urn:itu:t:BO.1073-1 → ITU-T BO.1073-1
    # - urn:itu:r:BO.500    → ITU-R BO.500
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)
        sector, code = parts
        flavor_parse("ITU-#{sector.upcase} #{code}")
      end
    end
  end
end
