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

      type "pubid:jis:all-parts", "all"
      type "pubid:jis:amendment", "amd"
      type "pubid:jis:corrigendum", "cor"
      type "pubid:jis:explanation", "e"
      type "pubid:jis:identifier", "id"
      type "pubid:jis:japanese-industrial-standard", "jis"
      type "pubid:jis:standard", "std"
      type "pubid:jis:technical-report", "tr"
      type "pubid:jis:technical-specification", "ts"
      type "pubid:jis:welding-engineering-standard", "wes"
    end
  end
end
