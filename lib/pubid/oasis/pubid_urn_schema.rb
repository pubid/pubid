# frozen_string_literal: true

module Pubid
  module Oasis
    # The pubid-scheme URN of oasis (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("oasis") do
      atom "part", "part"
      atom "version", "v"
      atom "stage", "stage"
      atom "label", "label"
      atom "original", "original"


      type "pubid:oasis:identifier", "id"
      type "pubid:oasis:standard", "std"
    end
  end
end
