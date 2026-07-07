# frozen_string_literal: true

module Pubid
  module Iala
    # Parses IALA MRN URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:mrn:iala:pub:<type-lower><number>[:ed<edition>][:<lang-lower>]
    #
    # Examples:
    #   urn:mrn:iala:pub:s1070:ed2.0          → IALA S1070 Ed 2.0
    #   urn:mrn:iala:pub:r1016:ed2.0:f        → IALA R1016 Ed 2.0 (F)
    #   urn:mrn:iala:pub:c0103-1              → IALA C0103-1
    class UrnParser < Pubid::UrnParser::Base
      PREFIX = "urn:mrn:iala:pub:".freeze

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)
        code = parts.fetch(0)

        edition = nil
        language = nil
        parts.drop(1).each do |seg|
          if seg.start_with?("ed")
            edition = seg.sub(/\Aed/, "")
          elsif seg.length == 1 && seg.match?(/\A[a-z]\z/i)
            language = seg.upcase
          end
        end

        text = "IALA #{code.upcase}"
        text += " Ed #{edition}" if edition
        text += " (#{language})" if language
        flavor_parse(text)
      end

      private

      def strip_namespace(urn)
        unless urn.downcase.start_with?(PREFIX)
          raise Pubid::UrnParser::Errors::ParseError,
                "Invalid IALA URN: #{urn.inspect}"
        end

        urn[PREFIX.length..]
      end
    end
  end
end
