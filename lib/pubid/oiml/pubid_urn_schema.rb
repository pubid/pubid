# frozen_string_literal: true

module Pubid
  module Oiml
    # The pubid-scheme URN of OIML (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   OIML D 2 (E)  ->  urn:pubid:oiml:document:2:pub-OIML:lang-E:format-...
    #
    # The number is the core of every type except the dual-published (no
    # core; its two nested identifiers ride +first-/second-). The atoms
    # follow the doc's canonical order; details in docs/URN-SCHEMES.adoc.
    PubidUrnSchema = Pubid::PubidUrn.define("oiml") do
      atom "publisher", "pub"
      atom "part", "part"
      atom "year", "year"
      atom "edition", "ed"
      atom "stage", "stage"
      atom "language", "lang"
      atom "amendment", "amendment"
      atom "family", "family"
      atom "iteration", "iteration"
      atom "letter", "letter"
      atom "trailing", "trailing", kind: :bool
      atom "first", "first", kind: :id
      atom "second", "second", kind: :id

      facet "parsed_format", "format"
      facet "space_separator", "sp", kind: :bool

      type "pubid:oiml:amendment", "amd"
      type "pubid:oiml:annex", "annex"
      type "pubid:oiml:basic-publication", "bp"
      type "pubid:oiml:bulletin", "bulletin"
      type "pubid:oiml:certification-system", "cs"
      type "pubid:oiml:document", "document"
      type "pubid:oiml:dual-published", "dp", core: []
      type "pubid:oiml:errata", "err"
      type "pubid:oiml:expert-report", "er"
      type "pubid:oiml:guide", "guide"
      type "pubid:oiml:identifier", "id", core: []
      type "pubid:oiml:recommendation", "rec"
      type "pubid:oiml:seminar-report", "sr"
      type "pubid:oiml:vocabulary", "v"
    end
  end
end
