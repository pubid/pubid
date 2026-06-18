# frozen_string_literal: true

module Pubid
  module Cie
    # Parses CIE URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:cie:cie:{code}:{year}:sep.colon
    #
    # The trailing `sep.colon` token records the code/year separator used
    # in the human-readable form (`:`). The leading `cie` after the
    # namespace is the lowercase publisher.
    #
    # Examples:
    # - urn:cie:cie:015:2018:sep.colon → CIE 015:2018
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body).reject { |p| p.start_with?("sep.") }

        _publisher, code, year = parts
        text = "CIE #{code}"
        text += ":#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
