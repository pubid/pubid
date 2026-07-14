# frozen_string_literal: true

module Pubid
  module Iala
    # Parses IALA MRN URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:mrn:iala:pub:<type-lower><number>[:ed<edition>][:<lang-lower>]
    # and for Annex identifiers:
    #   urn:mrn:iala:pub:<base-code>:annex[-<letter>][:ed<edition>][:<lang>]
    #
    # Examples:
    #   urn:mrn:iala:pub:s1070:ed2.0          → IALA S1070 Ed 2.0
    #   urn:mrn:iala:pub:r1016:ed2.0:f        → IALA R1016 Ed 2.0 (F)
    #   urn:mrn:iala:pub:c0103-1              → IALA C0103-1
    #   urn:mrn:iala:pub:g1045:annex:ed1      → IALA G1045 Annex Ed 1
    #   urn:mrn:iala:pub:g1128:annex-a:ed1.6  → IALA G1128 ANNEX A Ed 1.6
    class UrnParser < Pubid::UrnParser::Base
      PREFIX = "urn:mrn:iala:pub:".freeze

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)
        code = parts.fetch(0)

        edition = nil
        language = nil
        annex_form = nil
        annex_letter = nil

        parts.drop(1).each do |seg|
          case seg
          when /\Aannex(-([a-z]))?\z/i
            # UrnGenerator emits "annex" (bare) for the Annex-without-letter
            # form and "annex-X" (lettered) for the uppercase ANNEX form.
            # The human parser accepts both "Annex" and "ANNEX"; mirror the
            # generator's casing so URN round-trip is exact.
            annex_letter = Regexp.last_match(2)&.upcase
            annex_form = annex_letter ? "ANNEX" : "Annex"
          when /\Aed/
            edition = seg.sub(/\Aed/, "")
          when /\A[a-z]\z/i
            language = seg.upcase
          end
        end

        text = "IALA #{code.upcase}"
        text += " #{annex_form}" if annex_form
        text += " #{annex_letter}" if annex_letter
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
