# frozen_string_literal: true

module Pubid
  module Jcgm
    # Parses JCGM URNs back into identifiers.
    #
    # UrnGenerator emits `urn:jcgm:{number}:{year}` for guides and
    # `urn:jcgm:meeting:{number}:{year}` for committee/meeting records.
    #
    # Examples:
    # - urn:jcgm:200:2012 → JCGM 200:2012
    # - urn:jcgm:100:2008 → JCGM 100:2008
    # - urn:jcgm:meeting:17:2012 → JCGM 17th Meeting (2012)
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        parts = split_parts(strip_namespace(urn))
        return parse_meeting_urn(parts) if parts.first == "meeting"

        number, year = parts
        text = "JCGM #{number}"
        text += ":#{year}" if year
        flavor_parse(text)
      end

      private

      # urn:jcgm:meeting:<number>:<year> -> "JCGM <ordinal> Meeting (<year>)"
      def parse_meeting_urn(parts)
        _, number, year = parts
        ordinal = Identifiers::Meeting.ordinal(number)
        flavor_parse("JCGM #{ordinal} Meeting (#{year})")
      end
    end
  end
end
