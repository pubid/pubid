# frozen_string_literal: true

module Pubid
  module Ogc
    # The pubid-scheme URN of ogc (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("ogc") do
      atom "year", "year"
      atom "revision", "rev"


      type "pubid:ogc:document", "document"
      type "pubid:ogc:identifier", "id"
    end
  end
end
