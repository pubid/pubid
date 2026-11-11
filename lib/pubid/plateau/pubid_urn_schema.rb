# frozen_string_literal: true

module Pubid
  module Plateau
    # The pubid-scheme URN of PLATEAU (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   PLATEAU Handbook #00 第1.0版  ->  urn:pubid:plateau:hb:0:ed-1.0
    #
    # PLATEAU keeps +number+ as an Integer (the one flavor the String retype
    # left out), so it is an :int core. An Annex has no number of its own:
    # its document comes first, along +base+, and its letter is an atom.
    PubidUrnSchema = Pubid::PubidUrn.define("plateau") do
      atom "publisher", "pub"
      atom "edition", "ed"
      atom "annex", "annex", kind: :int
      atom "volume", "vol"

      number = [["number", :int]]
      type "pubid:plateau:annex", "annex", core: [],
                                           atoms: [%w[letter letter]]
      type "pubid:plateau:handbook", "hb", core: number
      type "pubid:plateau:identifier", "id", core: number
      type "pubid:plateau:technical-report", "tr", core: number
    end
  end
end
