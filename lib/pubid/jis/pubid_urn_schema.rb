# frozen_string_literal: true

module Pubid
  module Jis
    # The pubid-scheme URN of JIS (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   JIS A 0001:1999  ->  urn:pubid:jis:jis:0001:series-A:year-1999
    #
    # The current urn:jis:… form of #to_urn is pubid-invented and stays
    # there.
    PubidUrnSchema = Pubid::PubidUrn.define("jis") do
      atom "series", "series"
      atom "parts", "part", kind: :list
      atom "year", "year", kind: :int
      atom "reaffirmed", "reaffirmed", kind: :bool
      atom "language", "lang"
      # Where a WES id prints its language: "WES 1112(E):2022" against
      # "WES 1112:2022(E)". Spelling only.
      facet "language_before_year", "langfirst", kind: :bool

      type "pubid:jis:all-parts", "all"
      # A supplement's number is its Integer ordinal. The document it
      # supplements comes first, along +base+. An explanation can have no
      # number ("…/EXPL"), so its number is an atom.
      supplement = [["number", :int]]
      type "pubid:jis:amendment", "amd", core: supplement
      type "pubid:jis:corrigendum", "cor", core: supplement
      type "pubid:jis:explanation", "e", core: [],
                                         atoms: [["number", "n", :int]]
      type "pubid:jis:identifier", "id"
      type "pubid:jis:japanese-industrial-standard", "jis"
      type "pubid:jis:standard", "std"
      type "pubid:jis:technical-report", "tr"
      type "pubid:jis:technical-specification", "ts"
      type "pubid:jis:welding-engineering-standard", "wes"
      type "pubid:jis:welding-engineering-technical-report", "westr"
      type "pubid:jis:welding-engineering-technical-specification", "wests"
    end
  end
end
