# frozen_string_literal: true

module Pubid
  module Tgpp
    # The pubid-scheme URN of 3GPP (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   TS 01.01:REL-96/5.0.0  ->  urn:pubid:3gpp:ts:01.01:part-01:release-96:v-5.0.0
    #
    # The official urn:3gpp: namespace (RFC 5279) stays on #to_urn. The
    # parts ("01.01" splits to part "01" and part "01"…) are the list the
    # flavor models; the release and the version close the URN.
    PubidUrnSchema = Pubid::PubidUrn.define("3gpp") do
      atom "parts", "part", kind: :list
      atom "version", "v"
      atom "release", "release"
      atom "suffix", "suffix"

      type "pubid:3gpp:identifier", "id"
      type "pubid:3gpp:technical-report", "tr"
      type "pubid:3gpp:technical-specification", "ts"
    end
  end
end
