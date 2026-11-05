# frozen_string_literal: true

module Pubid
  module Iec
    # The pubid-scheme URN of IEC — PARTIAL (issue #656;
    # docs/URN-SCHEMES.adoc).
    #
    # Only the types other flavors nest are declared: the International
    # Standard (IEC/IEEE co-publications, GOST adoptions), and the TS, TR,
    # amendment and consolidated identifier a GOST adoption can name
    # ("IEC 60079-0:2017+AMD1:2020"). IEC's own wave declares the rest of the
    # flavor; until then IEC stays pending in the contract spec. The official
    # RFC 5141-style urn:iec:std: form stays on #to_urn.
    PubidUrnSchema = Pubid::PubidUrn.define("iec") do
      atom "publisher", "pub"
      atom "copublishers", "co", kind: :list
      atom "part", "part"
      atom "subpart", "subpart"
      atom "year", "year"
      atom "month", "month"
      atom "day", "day"
      atom "undated", "undated", kind: :bool
      atom "edition", "ed"
      atom "stage", "stage"
      atom "stage_iteration", "iter"
      atom "database", "database"
      atom "languages.*.code", "lang"
      atom "identifiers", "ids", kind: :ids

      facet "languages.*.original_code", "langsrc"

      type "pubid:iec:amendment", "amd"
      type "pubid:iec:consolidated-identifier", "consol", core: []
      type "pubid:iec:international-standard", "is"
      type "pubid:iec:technical-report", "tr"
      type "pubid:iec:technical-specification", "ts"
    end
  end
end
