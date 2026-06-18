# frozen_string_literal: true

module Pubid
  module Amca
    # Parses AMCA URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:amca:{number}:{year}[:{copub.publisher}[:{other tokens}]]
    #
    # The current generator can leak the Type Hash literal into the URN
    # (e.g., `copub.amca:{:key => :standard, ...}`). This parser filters
    # any token containing `{` so round-trip works for the common case.
    #
    # Examples:
    # - urn:amca:210:08              → AMCA 210-08
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body).reject { |p| p.include?("{") }

        number, year = parts
        text = "AMCA #{number}"
        text += "-#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
