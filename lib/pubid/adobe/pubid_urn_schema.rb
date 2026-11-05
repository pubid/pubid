# frozen_string_literal: true

module Pubid
  module Adobe
    # The pubid-scheme URN of adobe (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("adobe") do
      type "pubid:adobe:publication", "pub", core: []
      type "pubid:adobe:tech-note", "technote"
    end
  end
end
