# frozen_string_literal: true

module Pubid
  module Ashrae
    # Parses ASHRAE URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:ashrae:{number}:{year}:{type}[:{suffix}][:amd.{N}][:reaff.{Y}]
    #
    # The type token follows the year; the human-readable form prefixes the
    # type ("ASHRAE Standard 90.1-2019"). The year separator is `-`.
    #
    # Examples:
    # - urn:ashrae:90.1:2019:standard → ASHRAE Standard 90.1-2019
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        number, year = parts
        text = "ASHRAE Standard #{number}"
        text += "-#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
