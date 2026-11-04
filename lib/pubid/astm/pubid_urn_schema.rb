# frozen_string_literal: true

module Pubid
  module Astm
    # The pubid-scheme URN of ASTM (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   ASTM E2938-15(2023)
    #   urn:pubid:astm:std:2938:letter-E:year-2015:reapproval-2023
    #
    # The core is the document number; every other value is an optional
    # prefixed atom. Each suffix marker ("-EB", "-EA", "DVD", the metric
    # "M", the "TP" of a manual) names a different catalogue record, so all
    # are atoms and none is a facet. The current urn:astm: form of #to_urn
    # is pubid-invented and stays as it is.
    PubidUrnSchema = Pubid::PubidUrn.define("astm") do
      atom "publisher", "pub"
      atom "committee", "committee"
      atom "letter", "letter"
      atom "subseries", "subseries"
      atom "suffix", "suffix"
      atom "dual_m", "metric", kind: :bool
      atom "year", "year"
      atom "sub_year", "subyear"
      atom "reapproval", "reapproval"
      atom "edition", "ed"
      atom "supplement", "sup", kind: :bool
      atom "tp_designation", "tp"
      atom "format_suffix", "format"
      atom "ea_suffix", "ea", kind: :bool
      atom "dvd_suffix", "dvd", kind: :bool
      atom "hol_suffix", "hol", kind: :bool

      type "pubid:astm:identifier", "id"
      type "pubid:astm:single-identifier", "single"
      type "pubid:astm:base", "base"
      type "pubid:astm:standard", "std"
      type "pubid:astm:iso-dual-published", "isodual"
      type "pubid:astm:adjunct", "adj"
      type "pubid:astm:data-series", "ds"
      type "pubid:astm:manual", "mnl"
      type "pubid:astm:monograph", "mono"
      type "pubid:astm:research-report", "rr"
      type "pubid:astm:technical-report", "tr"
      type "pubid:astm:work-in-progress", "wk"
    end
  end
end
