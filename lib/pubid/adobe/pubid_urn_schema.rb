# frozen_string_literal: true

module Pubid
  module Adobe
    # The pubid-scheme URN of Adobe (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   Adobe Technical Note #5014  ->  urn:pubid:adobe:technote:5014
    #
    # A named publication has no positional core: its slug names it, and the
    # version (`adobe-japan1` + `7`) is an atom. The current urn:adobe:…
    # form of #to_urn is pubid-invented and stays there.
    PubidUrnSchema = Pubid::PubidUrn.define("adobe") do
      atom "slug", "slug"
      atom "version", "v"

      type "pubid:adobe:identifier", "id", core: []
      type "pubid:adobe:publication", "pub", core: []
      type "pubid:adobe:tech-note", "technote"
    end
  end
end
