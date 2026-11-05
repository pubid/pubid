# frozen_string_literal: true

module Pubid
  module Easc
    # The pubid-scheme URN of easc (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("easc") do
      atom "series", "series"
      atom "year", "year"
      atom "variant", "variant"


      type "pubid:easc:identifier", "id"
      type "pubid:easc:pmg", "pmg"
      type "pubid:easc:rmg", "rmg"
    end
  end
end
