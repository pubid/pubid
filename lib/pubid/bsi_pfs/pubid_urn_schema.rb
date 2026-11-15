  module Pubid
    module BsiPfs
      # The pubid-scheme URN schema, registered under the compiled
      # flavor key. The definition's declared namespace
      # ("bsi") is the scheme's canonical
      # namespace; identifiers carry the scheme's wire tag, so their
      # pubid URNs encode through the scheme's own schema.
      PubidUrnSchema = Pubid::PubidUrn.define("bsi_pfs") do
        atom "publisher", "pub"
        atom "part", "part"
        atom "year", "year"
        atom "adopted", "adopted", kind: :id
        atom "identifiers", "ids", kind: :ids
        type "pubid:bsi:adopted-european-norm", "aen", core: []
        type "pubid:bsi:adopted-international-standard", "ais", core: []
        type "pubid:bsi:amendment", "amd", core: []
        type "pubid:bsi:british-standard", "bs", core: ["number"]
        type "pubid:bsi:consolidated-identifier", "consol", core: []
        type "pubid:bsi:corrigendum", "cor", core: []
        type "pubid:bsi:draft-document", "dd", core: ["number"]
        type "pubid:bsi:published-document", "pd", core: ["number"]
        type "pubid:bsi:publicly-available-specification", "pas", core: ["number"]
        type "pubid:bsi:technical-specification", "ts", core: ["number"]
      end
    end
  end
