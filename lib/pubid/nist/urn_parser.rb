# frozen_string_literal: true

module Pubid
  module Nist
    # Parses NIST URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:nist:{type}:{code}[.{revision}].supp
    #
    # type is the lowercase series (sp, fips, ir, nistcir, …). code is the
    # alphanumeric designation. revision is `r{N}` when present. The `.supp`
    # suffix marks the series as supplementable.
    #
    # Examples:
    # - urn:nist:sp:800-53.supp        → NIST SP 800-53
    # - urn:nist:sp:800-53.r5.supp     → NIST SP 800-53r5
    # - urn:nist:fips:199.supp         → NIST FIPS 199
    class UrnParser < Pubid::UrnParser::Base
      TYPE_UPCASE = {
        "sp" => "SP",
        "fips" => "FIPS",
        "ir" => "IR",
        "nistcir" => "NISTCIR",
        "nbs" => "NBS",
        "nistir" => "NISTIR",
        "csf" => "CSF",
        "gcr" => "GCR",
        "itl" => "ITL",
        "jres" => "JRES",
        "lcirc" => "LCIRC",
        "mon" => "MONO",
        "ms" => "MS",
        "nsrds" => "NSRDS",
        "tn" => "TN",
        "wp" => "WP",
      }.freeze

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        type_token, payload = parts
        code, revision = parse_payload(payload)

        text = "NIST #{type_label(type_token)} #{code}"
        text += revision if revision
        flavor_parse(text)
      end

      private

      def parse_payload(payload)
        # Strip the trailing ".supp" supplement marker.
        stripped = payload.sub(/\.supp\z/, "")
        # Split revision suffix from code (e.g., "800-53.r5" → ["800-53", "r5"]).
        match = stripped.match(/^(.*)\.(r\d+)$/i)
        return [stripped, nil] unless match

        [match[1], match[2]]
      end

      def type_label(token)
        TYPE_UPCASE.fetch(token.downcase) { token.upcase }
      end
    end
  end
end
