# frozen_string_literal: true

module Pubid
  module Oiml
    # Parses OIML URNs back into identifiers.
    #
    # UrnGenerator emits: `urn:oiml:{type}:{locator}` where type is the
    # lowercase document class — single letter for typed documents
    # (r, d, b, g, …) or the word "bulletin" for Bulletin issues. The
    # locator is the number-part-subpart for typed documents and the
    # YYYY-II-SS tuple for Bulletins.
    #
    # Examples:
    # - urn:oiml:r:111-1           → OIML R 111-1
    # - urn:oiml:d:1               → OIML D 1
    # - urn:oiml:bulletin:2026-02-11 → OIML Bulletin 2026-02-11
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)
        type_token = parts.fetch(0)
        number = parts[1]

        text = "OIML #{display_type(type_token)}"
        text += " #{number}" if number
        flavor_parse(text)
      end

      private

      # URN type tokens are lowercase. Typed documents use a single letter
      # that maps cleanly via upcase; Bulletin is the multi-letter word
      # that the human parser expects capitalized.
      def display_type(token)
        token.downcase == "bulletin" ? "Bulletin" : token.upcase
      end
    end
  end
end
