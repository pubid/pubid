# frozen_string_literal: true

module Pubid
  module Gost
    # The pubid-scheme URN of GOST (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   ГОСТ ISO 6848  ->  urn:pubid:gost:is:6848:co-ISO
    #
    #   ГОСТ Р 58904-2020/ISO/TR 25901-1:2016
    #   urn:pubid:gost:ns:58904:year-2020:ia:58904:year-2020:
    #     adopted-(iso:tr:25901:part-1:year-2016)
    #
    # A harmonized or identical adoption wraps the GOST standard in +base+
    # (written first) and repeats its number and year, as #to_hash does.
    # The adopted documents are nested with their own flavor's schema
    # (cencenelec, iec, iso, ieee, astm).
    PubidUrnSchema = Pubid::PubidUrn.define("gost") do
      atom "publisher", "pub"
      atom "copublisher", "co"
      atom "year", "year"
      atom "subtype", "subtype"
      atom "raw", "raw"
      atom "adopted_identifiers", "adoptedidentifiers", kind: :ids
      atom "adopted", "adopted", kind: :id

      type "pubid:gost:foreign-reference", "fr"
      type "pubid:gost:harmonized", "h"
      type "pubid:gost:identical-adoption", "ia"
      type "pubid:gost:identifier", "id"
      type "pubid:gost:interstate-standard", "is"
      type "pubid:gost:national-standard", "ns"
    end
  end
end
