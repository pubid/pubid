# frozen_string_literal: true

module Pubid
  module Iho
    # Parses IHO URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:iho:{type-lower}:{number}[:{tag}.{value}]*[:{version}][:y.{year}]
    #
    # type-lower is the lowercase series letter (s, p, m, b, c).
    # tag is a lowercase label: part, ap, annex, suppl, vol, issue or y.
    # version is the dotted a.b.c edition, the only untagged tail.
    #
    # The number is not escaped, so it can span segments
    # ("IHO S-158:100" gives "urn:iho:s:158:100"). Every untagged
    # segment that is not a version therefore belongs to the number.
    #
    # Examples:
    # - urn:iho:s:44:5.0.0                → IHO S-44 5.0.0
    # - urn:iho:s:100:part.4a:1.0.0       → IHO S-100 Part 4a 1.0.0
    # - urn:iho:s:65:ap.A:1.0.0           → IHO S-65 Ap. A 1.0.0
    # - urn:iho:s:158:100:1.0.0           → IHO S-158:100 1.0.0
    # - urn:iho:p:5:y.2024                → IHO P-5 2024
    # - urn:iho:p:1:vol.30                → IHO P-1 Vol. 30
    # - urn:iho:p:1:vol.30:issue.2        → IHO P-1 Vol. 30 (2)
    class UrnParser < Pubid::UrnParser::Base
      # Tag => the text that the human-readable form prints for it.
      TAG_TEXT = {
        "part" => ->(v) { " Part #{v}" },
        "ap" => ->(v) { " Ap. #{v}" },
        "annex" => ->(v) { " Annex #{v}" },
        "suppl" => ->(v) { " Suppl #{v}" },
        "vol" => ->(v) { " Vol. #{v}" },
        "issue" => ->(v) { " (#{v})" },
        "y" => ->(v) { " #{v}" },
      }.freeze

      VERSION_SEGMENT = /\A\d+\.\d+\.\d+\z/

      def parse_urn(urn)
        type_token, first, *rest = split_parts(strip_namespace(urn))
        number = [first, *rest.take_while { |s| untagged_number?(s) }]
        tail = rest.drop(number.size - 1).map { |s| segment_text(s, urn) }
        flavor_parse("IHO #{type_token.upcase}-#{number.join(':')}#{tail.join}")
      end

      private

      def untagged_number?(segment)
        !tagged?(segment) && !segment.match?(VERSION_SEGMENT)
      end

      def tagged?(segment)
        segment.match?(/\A[a-z]+\./i)
      end

      def segment_text(segment, urn)
        return " #{segment}" if segment.match?(VERSION_SEGMENT)

        tag, value = segment.split(".", 2)
        render = TAG_TEXT[tag.downcase] if tagged?(segment)
        unless render
          raise Pubid::Errors::UrnParseError,
                "Unexpected segment #{segment.inspect} in #{urn.inspect}"
        end

        render.call(value)
      end
    end
  end
end
