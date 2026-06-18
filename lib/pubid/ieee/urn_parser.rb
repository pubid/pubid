# frozen_string_literal: true

module Pubid
  module Ieee
    # Parses IEEE URNs back into identifiers.
    #
    # UrnGenerator emits many fields; this parser handles the common
    # published-standard shape:
    #   urn:ieee:{publisher}:{code}:{year}
    #
    # publisher is the lowercase publisher (with optional copublishers
    # joined by `-`). code is the alphanumeric designation (period is the
    # part separator within the code). The year separator in human-readable
    # form is `-`.
    #
    # Examples:
    # - urn:ieee:ieee:802.3:2018 → IEEE Std 802.3-2018
    # - urn:ieee:ieee:1018:2019  → IEEE Std 1018-2019
    class UrnParser < Pubid::UrnParser::Base
      PUBLISHER_LABEL = "IEEE"

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        _publisher, code, year = parts

        text = "#{PUBLISHER_LABEL} Std #{code}"
        text += "-#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
