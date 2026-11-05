# frozen_string_literal: true

module Pubid
  module CenCenelec
    # The pubid-scheme URN of CEN/CENELEC (issue #670 completes the flavor;
    # docs/URN-SCHEMES.adoc).
    #
    #   EN 302 326-2 V2.2.1:2026  ->
    #   urn:pubid:cencenelec:en:302~20326:part-2:year-2026:v-~20V2.2.1
    #
    # The partial schema landed with GOST named the types a GOST adoption
    # can reach; this wave adds the rest of the flavor (CR, CWA, the two
    # harmonization documents, the prestandard, the specification, the
    # fragment and the guides) and the `subpart` and nested-date atoms. An
    # absent atom writes nothing, and every new atom sits after the ones
    # the GOST wave placed, so the URNs it publishes are unchanged. The
    # adopted document goes along +base+ and keeps its own flavor's schema;
    # a consolidated identifier has only its `identifiers`
    # (`urn:pubid:cencenelec:consol:ids-(cencenelec:en:14988:year-2017),…`).
    PubidUrnSchema = Pubid::PubidUrn.define("cencenelec") do
      atom "publisher", "pub"
      atom "copublishers", "co", kind: :list
      atom "part", "part"
      atom "subpart", "subpart"
      atom "year", "year"
      atom "month", "month"
      atom "date.year", "dateyear"
      atom "date.month", "datemonth"
      atom "version", "v"
      atom "stage", "stage"
      atom "adopted", "adopted", kind: :id
      atom "identifiers", "ids", kind: :ids

      type "pubid:cencenelec:adopted-european-norm", "aen", core: []
      type "pubid:cencenelec:amendment", "amd"
      type "pubid:cencenelec:base", "base"
      type "pubid:cencenelec:cen-report", "cr"
      type "pubid:cencenelec:cen-workshop-agreement", "cwa"
      type "pubid:cencenelec:cenelec-harmonization-document", "chd"
      type "pubid:cencenelec:consolidated-identifier", "consol", core: []
      type "pubid:cencenelec:corrigendum", "cor"
      type "pubid:cencenelec:european-norm", "en"
      type "pubid:cencenelec:european-prestandard", "ep"
      type "pubid:cencenelec:european-specification", "es"
      type "pubid:cencenelec:fragment", "fragment"
      type "pubid:cencenelec:guide", "guide"
      type "pubid:cencenelec:harmonization-document", "hd"
      type "pubid:cencenelec:identifier", "id"
      type "pubid:cencenelec:technical-report", "tr"
      type "pubid:cencenelec:technical-specification", "ts"
    end
  end
end
