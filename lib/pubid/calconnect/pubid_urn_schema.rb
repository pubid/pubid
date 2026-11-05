# frozen_string_literal: true

module Pubid
  module Calconnect
    # The pubid-scheme URN of calconnect (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("calconnect") do
      atom "series", "series"
      atom "year", "year"
      atom "month", "month"
      atom "day", "day"


      type "pubid:calconnect:identifier", "id"
      type "pubid:calconnect:standard", "std"
    end
  end
end
