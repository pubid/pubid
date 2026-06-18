# frozen_string_literal: true

module Pubid
  module Csa
    # Parses CSA URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:csa:{publisher}:{code}:{year}:format.{format}
    #
    # The trailing `format.X` token records the year-separator style used
    # in the human-readable form (`dash` for `-`, `colon` for `:`).
    #
    # Examples:
    # - urn:csa:csa:Z240.2.1:16:format.dash → CSA Z240.2.1-16
    class UrnParser < Pubid::UrnParser::Base
      YEAR_SEPARATOR = { "dash" => "-", "colon" => ":" }.freeze

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        format_token = parts.find { |p| p.start_with?("format.") }
        separator = YEAR_SEPARATOR.fetch(format_token&.split(".")&.last, "-")

        payload = parts.reject { |p| p.start_with?("format.") }
        _publisher, code, year = payload
        text = "CSA #{code}"
        text += "#{separator}#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
