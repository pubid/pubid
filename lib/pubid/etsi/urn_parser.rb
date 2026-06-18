# frozen_string_literal: true

module Pubid
  module Etsi
    # Parses ETSI URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:etsi:{type}:{code}:{version}:{date}[:{supplement_notation}:{number}]
    #
    # type is the lowercase type abbreviation (en, ets, ts, tr, gs, sr).
    # code is the identifier code with internal whitespace preserved.
    # version is the lowercase Vx.y.z form.
    # date is YYYY or YYYY-MM.
    #
    # Examples:
    # - urn:etsi:en:300 100:v1.1.1:1998-04 → ETSI EN 300 100 V1.1.1 (1998-04)
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        type_token = parts.fetch(0).upcase
        code = parts.fetch(1)
        version = parts[2]
        date = parts[3]

        text = "ETSI #{type_token} #{code}"
        text += " #{version.upcase}" if version
        text += " (#{date})" if date
        flavor_parse(text)
      end
    end
  end
end
