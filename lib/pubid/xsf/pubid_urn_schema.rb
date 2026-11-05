# frozen_string_literal: true

module Pubid
  module Xsf
    # The pubid-scheme URN of xsf (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("xsf") do
      type "pubid:xsf:identifier", "id"
      type "pubid:xsf:xep", "xep"
    end
  end
end
