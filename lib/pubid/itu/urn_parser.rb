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
      # UrnGenerator emits a type segment between the sector and the code for
      # the series that number independently of the Recommendation series:
      # urn:itu:r:report:BT.2020-1, urn:itu:r:resolution:1-9.
      TYPE_SEGMENTS = { "report" => "Report", "resolution" => "Resolution" }
        .freeze

      def parse_urn(urn)
        sector, *rest = split_parts(strip_namespace(urn))
        word = TYPE_SEGMENTS[rest.first]
        return flavor_parse("#{word} ITU-#{sector.upcase} #{rest[1]}") if word

        flavor_parse("ITU-#{sector.upcase} #{rest.first}")
      end
    end
  end
end
