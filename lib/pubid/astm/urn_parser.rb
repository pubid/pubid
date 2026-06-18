# frozen_string_literal: true

module Pubid
  module Astm
    # Parses ASTM URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:astm:{publisher}:{code}:{year}[:sub_year][:reapp.X][:eX][:wip][:wk.X]
    #
    # The publisher slot is the lowercase publisher string ("astm" or
    # "pub-copub"). The code slot is the alphanumeric ASTM code (e.g.,
    # "D2148", "A1"). Year is **2 digits** in the URN.
    #
    # Examples:
    # - urn:astm:astm:D2148:2022  → ASTM D2148-22
    # - urn:astm:astm:A1:2002     → ASTM A1-02
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        _publisher, code, year = parts

        text = "ASTM #{code}"
        text += "-#{year[-2..]}" if year && year.length >= 2
        flavor_parse(text)
      end
    end
  end
end
