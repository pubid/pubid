# frozen_string_literal: true

module Pubid
  module Sae
    # Parses SAE URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:sae:{type|std}:{designation}[:{yyyy|yyyymm}]
    # where slot[1] is overwritten with the publisher string when a publisher
    # is set. The common single-publisher case keeps slot[1] = "sae".
    #
    # Examples:
    # - urn:sae:j:300:2019     → SAE J300:2019
    # - urn:sae:air:500        → SAE AIR500
    # - urn:sae:ams:5000:2020  → SAE AMS5000:2020
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        type_token, number, year = parts
        text = build_text(type_token, number, year)
        flavor_parse(text)
      end

      private

      # The designation follows the type with no separator; the grammar
      # reads a glued number for every family. A six-digit date segment is
      # SAE's year-and-month edition date.
      def build_text(type_token, number, year)
        head = type_token == "std" ? "" : type_token.upcase
        # The designation's letters are upper-case in every SAE code; a URN
        # that a consumer lower-cased (urn:sae:ams:4121j) still resolves.
        text = "SAE #{head}#{number.to_s.upcase}"
        text += "#{year.to_s.length == 6 ? '_' : ':'}#{year}" if year
        text
      end
    end
  end
end
