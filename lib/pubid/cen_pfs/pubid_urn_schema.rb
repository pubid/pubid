  module Pubid
    module CenPfs
      # The pubid-scheme URN schema, registered under the compiled
      # flavor key. The definition's declared namespace
      # ("cen") is the scheme's canonical
      # namespace; identifiers carry the scheme's wire tag, so their
      # pubid URNs encode through the scheme's own schema.
      PubidUrnSchema = Pubid::PubidUrn.define("cen_pfs") do
        atom "part", "part"
        atom "year", "year"
        type "pubid:cencenelec:identifier", "id", core: []
        type "pubid:cencenelec:european-norm", "en", core: ["number"]
      end
    end
  end
