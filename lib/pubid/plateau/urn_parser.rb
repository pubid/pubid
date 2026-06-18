# frozen_string_literal: true

module Pubid
  module Plateau
    # Parses Plateau URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:plateau:{type}:{number}[:{annex}]
    #
    # type is one of: handbook, tr (technical report), an (annex), or another
    # lowercase type string. Annex is a zero-padded 2-digit string when present.
    #
    # Examples:
    # - urn:plateau:handbook:00        → PLATEAU Handbook #00
    # - urn:plateau:tr:01              → PLATEAU Technical Report #01
    class UrnParser < Pubid::UrnParser::Base
      TYPE_MAP = {
        "handbook" => "Handbook",
        "tr" => "Technical Report",
        "an" => "Annex",
      }.freeze

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        type_token = parts.fetch(0)
        number = parts.fetch(1)
        annex = parts[2]

        text = "PLATEAU #{display_type(type_token)} ##{number}"
        text += "-#{annex}" if annex
        flavor_parse(text)
      end

      private

      def display_type(token)
        TYPE_MAP.fetch(token) { token.capitalize }
      end
    end
  end
end
