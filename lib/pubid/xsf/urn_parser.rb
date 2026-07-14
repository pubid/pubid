# frozen_string_literal: true

module Pubid
  module Xsf
    # Parses XSF URNs back into identifiers.
    #
    # UrnGenerator emits: `urn:xsf:xep:<number>` (e.g. urn:xsf:xep:0001).
    # This inverts it by reconstructing the printed "XEP <number>" string and
    # delegating to the flavor's text parser.
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        _type, number = split_parts(body)
        flavor_parse("XEP #{number}")
      end
    end
  end
end
