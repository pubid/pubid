# frozen_string_literal: true

module Pubid
  module Ccsds
    # The pubid-scheme URN of ccsds (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("ccsds") do
      atom "type", "type"
      atom "part", "part"
      atom "edition", "ed"
      atom "language", "lang"
      atom "suffix", "suffix"


      type "pubid:ccsds:base", "base"
      type "pubid:ccsds:corrigendum", "cor"
      type "pubid:ccsds:identifier", "id"
    end
  end
end
