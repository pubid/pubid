# frozen_string_literal: true

module Pubid
  module CenCenelec
    # Parses CEN/CENELEC URNs back into identifiers.
    #
    # UrnGenerator emits: `urn:cen:{type}:{number}:{year}` where type is
    # the lowercase document class (en, etsg, ts, tr).
    #
    # Examples:
    # - urn:cen:en:9001:2015 → EN 9001:2015
    class UrnParser < Pubid::UrnParser::Base
      # UrnGenerator uses "cen" rather than "cencenelec" as the namespace.
      def flavor_name
        "cen"
      end

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)
        type_token, number, year = parts
        text = "#{type_token.upcase} #{number}"
        text += ":#{year}" if year
        flavor_parse(text)
      end
    end
  end
end
