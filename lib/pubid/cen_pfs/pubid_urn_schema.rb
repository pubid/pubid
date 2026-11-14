  module Pubid
    module CenPfs
      # The pubid-scheme URN schema, registered under the compiled
      # flavor key. The definition's declared namespace
      # ("cen") is the scheme's canonical
      # namespace; identifiers carry the scheme's wire tag, so their
      # pubid URNs encode through the scheme's own schema.
      PubidUrnSchema = Pubid::PubidUrn.define("cen_pfs") do
        atom "publisher", "pub"
        atom "copublishers", "co", kind: :list
        atom "part", "part"
        atom "year", "year"
        atom "version", "v"
        atom "stage", "stage"
        atom "adopted", "adopted", kind: :id
        atom "identifiers", "ids", kind: :ids
        type "pubid:cencenelec:adopted-european-norm", "aen", core: []
        type "pubid:cencenelec:amendment", "amd", core: []
        type "pubid:cencenelec:cen-report", "cr", core: []
        type "pubid:cencenelec:cen-workshop-agreement", "cwa", core: []
        type "pubid:cencenelec:consolidated-identifier", "consol", core: []
        type "pubid:cencenelec:corrigendum", "cor", core: []
        type "pubid:cencenelec:european-norm", "en", core: []
        type "pubid:cencenelec:european-prestandard", "ep", core: []
        type "pubid:cencenelec:european-specification", "es", core: []
        type "pubid:cencenelec:fragment", "fragment", core: []
        type "pubid:cencenelec:guide", "guide", core: []
        type "pubid:cencenelec:harmonization-document", "hd", core: []
        type "pubid:cencenelec:identifier", "id", core: []
        type "pubid:cencenelec:technical-report", "tr", core: []
        type "pubid:cencenelec:technical-specification", "ts", core: []
      end
    end
  end
