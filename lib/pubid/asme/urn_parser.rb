# frozen_string_literal: true

module Pubid
  module Asme
    # Parses ASME URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:asme:{publisher}:{code}:{year}
    #
    # publisher is the lowercase publisher string. code is the alphanumeric
    # designation (e.g., "B16.5", "PTC1", "BPVC-2023"). The year separator
    # in human-readable form is `-`, not `:`.
    #
    # Examples:
    # - urn:asme:asme:B16.5:2020   → ASME B16.5-2020
    # - urn:asme:asme:PTC1:2020    → ASME PTC1-2020
    # - urn:asme:asme:BPVC-2023    → ASME BPVC-2023
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        _publisher, code, year = parts

        text = "ASME #{code}"
        text += "-#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
