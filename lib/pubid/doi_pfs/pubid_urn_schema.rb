  module Pubid
    module DoiPfs
      # The pubid-scheme URN schema, registered under the compiled
      # flavor key. The definition's declared namespace
      # ("doi") is the scheme's canonical
      # namespace; identifiers carry the scheme's wire tag, so their
      # pubid URNs encode through the scheme's own schema.
      PubidUrnSchema = Pubid::PubidUrn.define("doi_pfs") do
        atom "prefix", "prefix"
        atom "suffix", "suffix"
        type "pubid:doi_pfs:identifier", "id", core: []
        type "pubid:doi_pfs:resource", "resource", core: []
      end
    end
  end
