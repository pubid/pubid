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
        type "pubid:etsi_pfs:identifier", "id", core: []
        type "pubid:etsi_pfs:standard", "es", core: []
      end
    end
  end
