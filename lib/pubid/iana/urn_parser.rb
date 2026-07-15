# frozen_string_literal: true

module Pubid
  module Iana
    # Parses IANA URNs back into identifiers.
    #
    # UrnGenerator emits `urn:iana:<registry>[:<sub_registry>]`; this rebuilds
    # the bare slug and delegates to the flavor's text parser (which normalizes
    # it back to the "IANA "-prefixed printed form).
    #
    # Examples:
    # - urn:iana:calipso -> IANA calipso
    # - urn:iana:_6lowpan-parameters:lowpan_nhc
    #     -> IANA _6lowpan-parameters/lowpan_nhc
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        registry, sub_registry = split_parts(body)
        slug = sub_registry ? "#{registry}/#{sub_registry}" : registry
        flavor_parse(slug)
      end
    end
  end
end
