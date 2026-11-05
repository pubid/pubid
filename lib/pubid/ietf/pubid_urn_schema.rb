# frozen_string_literal: true

module Pubid
  module Ietf
    # The pubid-scheme URN of IETF (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   draft-3gpp-collaboration-01  ->
    #   urn:pubid:ietf:id2:3gpp-collaboration:v-01
    #
    # The official urn:ietf:rfc:… namespace (RFC 2648) stays on #to_urn.
    # The internet-draft token is `id2`, because `id` names the flavor's
    # bare identifier.
    PubidUrnSchema = Pubid::PubidUrn.define("ietf") do
      atom "version", "v"

      type "pubid:ietf:bcp", "bcp"
      type "pubid:ietf:fyi", "fyi"
      type "pubid:ietf:identifier", "id"
      type "pubid:ietf:internet-draft", "id2"
      type "pubid:ietf:rfc", "rfc"
      type "pubid:ietf:std", "std"
    end
  end
end
