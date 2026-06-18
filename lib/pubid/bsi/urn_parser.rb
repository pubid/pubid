# frozen_string_literal: true

module Pubid
  module Bsi
    # Parses BSI URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:bsi:{publisher}:{number}:{year}[:{supp_type}:{supp_number}:{supp_year}]
    #
    # publisher is the lowercase publisher (e.g., "bs", "pd"). supplement
    # triples (`amd`/`cor`/`add`) follow the base identifier.
    #
    # Examples:
    # - urn:bsi:bs:9001:2015                → BS 9001:2015
    # - urn:bsi:bs:9001:2015:amd:1:2020     → BS 9001:2015/A1:2020
    class UrnParser < Pubid::UrnParser::Base
      SUPPLEMENT_ABBR = {
        "amd" => "Amd",
        "cor" => "Cor",
        "add" => "Add",
      }.freeze

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        publisher_token, number, year, *supplement_parts = parts
        publisher = publisher_token.upcase
        text = "#{publisher} #{number}"
        text += ":#{year}" if year
        text += build_supplements(supplement_parts)
        flavor_parse(text)
      end

      private

      def build_supplements(parts)
        return "" if parts.empty?

        chunks = parts.each_slice(3).to_a
        chunks.map { |type, num, supp_year| render_supplement(type, num, supp_year) }.join
      end

      def render_supplement(type, num, supp_year)
        label = SUPPLEMENT_ABBR.fetch(type.downcase) { type.capitalize }
        suffix = num ? " #{num}" : ""
        suffix += ":#{supp_year}" if supp_year
        "/#{label}#{suffix}"
      end
    end
  end
end
