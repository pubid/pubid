# frozen_string_literal: true

module Pubid
  module Evs
    # The pubid-scheme URN of evs (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("evs") do
      atom "part", "part"
      atom "year", "year"
      atom "language", "lang"
      atom "amd_kind", "amdkind"
      atom "amd_number", "amdnumber"
      atom "amd_year", "amdyear"
      atom "cor_kind", "corkind"
      atom "cor_year", "coryear"
      atom "evs_type", "evstype"
      atom "intl_org", "intlorg"
      atom "na_year", "nayear"


      facet "separator", "separator"
      facet "amd_separator", "amdseparator"
      facet "cor_separator", "corseparator"
      facet "na_separator", "naseparator"
      facet "draft_prefix", "draftprefix", kind: :bool

      type "pubid:evs:estonian-standard", "es"
      type "pubid:evs:identifier", "id"
      type "pubid:evs:international-adoption", "ia"
      type "pubid:evs:national-adoption", "na"
    end
  end
end
