# frozen_string_literal: true

module Pubid
  module CenCenelec
    # The pubid-scheme URN of CEN/CENELEC — PARTIAL (issue #656;
    # docs/URN-SCHEMES.adoc).
    #
    # Only the types a GOST adoption can name are declared: an EN, an
    # adopted EN ("EN ISO 12100:2010", no number of its own), its amendment
    # and corrigendum, a CEN TS or TR, and the consolidated
    # "EN 14988:2017+A1:2020". The atoms keep the doc's canonical order; an
    # absent atom writes nothing, so the CEN wave can add types and atoms
    # without changing these URNs. Until then cen_cenelec stays pending in
    # the contract spec.
    PubidUrnSchema = Pubid::PubidUrn.define("cencenelec") do
      atom "publisher", "pub"
      atom "copublishers", "co", kind: :list
      atom "part", "part"
      atom "year", "year"
      atom "month", "month"
      atom "version", "v"
      atom "stage", "stage"
      atom "adopted", "adopted", kind: :id
      atom "identifiers", "ids", kind: :ids

      type "pubid:cencenelec:adopted-european-norm", "aen", core: []
      type "pubid:cencenelec:amendment", "amd"
      type "pubid:cencenelec:consolidated-identifier", "consol", core: []
      type "pubid:cencenelec:corrigendum", "cor"
      type "pubid:cencenelec:european-norm", "en"
      type "pubid:cencenelec:technical-report", "tr"
      type "pubid:cencenelec:technical-specification", "ts"
    end
  end
end
