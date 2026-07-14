# frozen_string_literal: true

module Pubid
  module W3c
    # Parses W3C URNs back into identifiers by reconstructing the printed form
    # and delegating to the flavor's text parser.
    #
    # UrnGenerator emits `urn:w3c:<type-down>:<code>[:<date>]`. The first body
    # segment is the maturity token only when it is one of the known tokens AND
    # a code segment follows it (a typed URN always has ≥2 segments); a
    # single-segment body is always a bare code — even one that happens to spell
    # a token, e.g. `urn:w3c:rec` -> `W3C rec` (a Standard, not a REC).
    #
    # Examples:
    # - urn:w3c:wd:charmod:19991129 -> W3C WD-charmod-19991129
    # - urn:w3c:note:xml-names      -> W3C NOTE-xml-names
    # - urn:w3c:2dcontext           -> W3C 2dcontext
    class UrnParser < Pubid::UrnParser::Base
      KNOWN_TOKENS = %w[note dnote wd cr crd rec pr per spsd obsl].freeze

      def parse_urn(urn)
        parts = split_parts(strip_namespace(urn))

        if parts.size > 1 && KNOWN_TOKENS.include?(parts.first)
          token = parts.shift.upcase
          text = "W3C #{token}-#{parts.shift}"
        else
          text = "W3C #{parts.shift}"
        end
        text += "-#{parts.shift}" unless parts.empty?

        flavor_parse(text)
      end
    end
  end
end
