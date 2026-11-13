  module Pubid
    module EtsiPfs
      # The pubid-scheme URN schema, registered under the compiled
      # flavor key. The definition's declared namespace
      # ("etsi") is the scheme's canonical
      # namespace; identifiers carry the scheme's wire tag, so their
      # pubid URNs encode through the scheme's own schema.
      PubidUrnSchema = Pubid::PubidUrn.define("etsi_pfs") do
        atom "type", "type"
        atom "parts", "part"
        atom "minor", "minor"
        atom "year", "year"
        atom "month", "month"
        atom "version", "v"
        type "pubid:etsi:etsi-standard", "es", core: []
        type "pubid:etsi:amendment", "amd", core: [["number", :int]]
        type "pubid:etsi:corrigendum", "cor", core: [["number", :int]]
        type "pubid:etsi:identifier", "id", core: []
      end
    end
  end
