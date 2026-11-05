# frozen_string_literal: true

module Pubid
  module Doi
    # The pubid-scheme URN of DOI (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   doi:10.1000/182  ->  urn:pubid:doi:resource:prefix-10.1000:suffix-182
    #
    # The official urn:doi: namespace (the IANA formal template) stays on
    # #to_urn.
    PubidUrnSchema = Pubid::PubidUrn.define("doi") do
      atom "prefix", "prefix"
      atom "suffix", "suffix"

      type "pubid:doi:identifier", "id", core: []
      type "pubid:doi:resource", "resource", core: []
    end
  end
end
