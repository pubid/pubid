# frozen_string_literal: true

module Pubid
  module Iana
    # The pubid-scheme URN of iana (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("iana") do
      atom "sub_registry", "subregistry"


      type "pubid:iana:identifier", "id", core: []
      type "pubid:iana:registry", "registry"
    end
  end
end
