  module Pubid
    module CalconnectPfs
      # The pubid-scheme URN schema, registered under the compiled
      # flavor key. The definition's declared namespace
      # ("calconnect") is the scheme's canonical
      # namespace; identifiers carry the scheme's wire tag, so their
      # pubid URNs encode through the scheme's own schema.
      PubidUrnSchema = Pubid::PubidUrn.define("calconnect_pfs") do
        atom "series", "series"
        atom "year", "year"
        atom "month", "month"
        atom "day", "day"
        type "pubid:calconnect:identifier", "id", core: []
        type "pubid:calconnect:standard", "std", core: ["number"]
      end
    end
  end
