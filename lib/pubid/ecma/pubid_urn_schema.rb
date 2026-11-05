# frozen_string_literal: true

module Pubid
  module Ecma
    # The pubid-scheme URN of ecma (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("ecma") do
      atom "part", "part"
      atom "volume", "vol"
      atom "edition", "ed"


      type "pubid:ecma:identifier", "id"
      type "pubid:ecma:memento", "memento"
      type "pubid:ecma:standard", "std"
      type "pubid:ecma:technical-report", "tr"
    end
  end
end
