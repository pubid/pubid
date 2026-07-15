# frozen_string_literal: true

module Pubid
  module Oasis
    # Parses OASIS URNs back into identifiers by reconstructing the printed form
    # and delegating to the flavor's text parser.
    #
    # UrnGenerator emits `urn:oasis:<slug>` (single segment) with the space and
    # "]" characters percent-encoded; reverse exactly those two here.
    #
    #   urn:oasis:OSLC-CM-v1.0-CS01 -> OASIS OSLC-CM-v1.0-CS01
    #   urn:oasis:amqp-core         -> OASIS amqp-core
    class UrnParser < Pubid::UrnParser::Base
      DECODE = { "%20" => " ", "%5D" => "]" }.freeze

      def parse_urn(urn)
        slug = strip_namespace(urn).gsub(/%20|%5D/, DECODE)
        flavor_parse("OASIS #{slug}")
      end
    end
  end
end
