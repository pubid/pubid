# frozen_string_literal: true

module Pubid
  module Iho
    # Parses IHO URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:iho:{type-lower}:{number}[:{part-kind}.{part}][:{version|year|vol.N[.issue.N]}]
    #
    # type-lower is the lowercase series letter (s, p, m, b, c).
    # part-kind is the lowercase part label (part, ap, annex, suppl,
    # vol, issue).
    # The trailing segment is the dotted version, a bare year, or the
    # volume/issue pair.
    #
    # Examples:
    # - urn:iho:s:44:5.0.0                → IHO S-44 5.0.0
    # - urn:iho:s:100:part.4a:1.0.0       → IHO S-100 Part 4a 1.0.0
    # - urn:iho:s:65:ap.A:1.0.0           → IHO S-65 Ap. A 1.0.0
    # - urn:iho:p:5:2024                  → IHO P-5 2024
    # - urn:iho:p:1:vol.30                → IHO P-1 Vol. 30
    # - urn:iho:p:1:vol.30.issue.2        → IHO P-1 Vol. 30 (2)
    class UrnParser < Pubid::UrnParser::Base
      PART_LABELS = {
        "part" => "Part",
        "ap" => "Ap.",
        "annex" => "Annex",
        "suppl" => "Suppl",
        "vol" => "Vol.",
      }.freeze

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        type_token = parts.fetch(0).upcase
        number = parts.fetch(1)
        idx = 2
        text = "IHO #{type_token}-#{number}"
        # Part-kind tokens come in any run (a volume may carry an issue
        # beside it); "issue.N" prints as the parenthesized issue.
        while parts[idx] && part_kind?(parts[idx])
          kind, value = parts[idx].split(".", 2)
          if kind.downcase == "issue"
            text += " (#{value})"
          else
            label = PART_LABELS.fetch(kind.downcase) { kind.capitalize }
            text += " #{label} #{value}"
          end
          idx += 1
        end
        tail = parts[idx]

        text += " #{tail}" if tail
        flavor_parse(text)
      end

      private

      # A part-kind token starts with letters followed by a dot, e.g.,
      # "part.4a", "ap.A", "annex.A", "suppl.1". A version like "5.0.0"
      # starts with a digit.
      def part_kind?(token)
        token.match?(/^[a-z]+\./i)
      end
    end
  end
end
