# frozen_string_literal: true

module Pubid
  module Etsi
    # The pubid-scheme URN of ETSI (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   ETSI EN 300 175-1 V2.9.1 (2022-01)
    #   urn:pubid:etsi:es:300~20175:type-EN:part-1:year-2022:month-01:v-2.9.1
    #
    #   ETSI ETR 108/A1 ed.1 (1995-08)
    #   urn:pubid:etsi:es:108:type-ETR:year-1995:month-08:v-1:isedition-true:
    #     amd:1
    #
    # The number is the core of every type. A supplement's number is its
    # Integer ordinal, so it is an :int core; the document it supplements
    # comes first, along +base+. The official urn:etsi: form (RFC 8515)
    # stays on #to_urn.
    PubidUrnSchema = Pubid::PubidUrn.define("etsi") do
      atom "type", "type"
      atom "parts", "part", kind: :list
      atom "minor", "minor"
      atom "year", "year"
      atom "month", "month"
      atom "day", "day"
      atom "version", "v"
      atom "is_edition", "isedition", kind: :bool

      supplement = [["number", :int]]
      type "pubid:etsi:amendment", "amd", core: supplement
      type "pubid:etsi:corrigendum", "cor", core: supplement
      type "pubid:etsi:etsi-standard", "es"
      type "pubid:etsi:identifier", "id"
      type "pubid:etsi:supplement-identifier", "si", core: supplement
    end
  end
end
