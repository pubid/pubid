# frozen_string_literal: true

module Pubid
  module Iho
    # Parses IHO URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:iho:{type-lower}:{number}[:{tag}.{value}]...[:{version}]
    #
    # type-lower is the lowercase series letter (s, p, m, b, c).
    # tag is a lowercase label: part, ap, annex, suppl (document parts) or
    # y, vol, no (year, volume and issue of a series publication).
    # version is the untagged dotted version string.
    #
    # Examples:
    # - urn:iho:s:44:5.0.0                → IHO S-44 5.0.0
    # - urn:iho:s:100:part.4a:1.0.0       → IHO S-100 Part 4a 1.0.0
    # - urn:iho:s:65:ap.A:1.0.0           → IHO S-65 Ap. A 1.0.0
    # - urn:iho:p:5:y.2024                → IHO P-5 2024
    # - urn:iho:p:1:vol.30:no.1           → IHO P-1 Vol. 30 No. 1
    class UrnParser < Pubid::UrnParser::Base
      # Tag → the text the human-readable form prints before the value
      # (nil prints the value alone, as for the year).
      TAG_LABELS = {
        "part" => "Part",
        "ap" => "Ap.",
        "annex" => "Annex",
        "suppl" => "Suppl",
        "y" => nil,
        "vol" => "Vol.",
        "no" => "No.",
      }.freeze

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        type_token = parts.fetch(0).upcase
        number = parts.fetch(1)
        text = "IHO #{type_token}-#{number}"
        parts.drop(2).each { |token| text += " #{segment_text(token)}" }
        flavor_parse(text)
      end

      private

      # A tagged token starts with letters followed by a dot, e.g.
      # "part.4a", "ap.A", "y.2024", "vol.30". The only untagged token is
      # the dotted version ("5.0.0"), printed as it is. Any other untagged
      # token is refused: the number may hold an unescaped colon
      # ("S-158:100"), and "urn:iho:s:158:2024" must not decode to the
      # year 2024 of IHO S-158.
      def segment_text(token)
        return tagged_text(token) if token.match?(/\A[a-z]+\./i)
        return token if token.match?(/\A\d+\.\d+\.\d+\z/)

        raise Pubid::Errors::UrnParseError,
              "Unexpected IHO URN segment: #{token.inspect}"
      end

      def tagged_text(token)
        tag, value = token.split(".", 2)
        tag = tag.downcase
        label = TAG_LABELS.fetch(tag) { tag.capitalize }
        label ? "#{label} #{value}" : value
      end
    end
  end
end
