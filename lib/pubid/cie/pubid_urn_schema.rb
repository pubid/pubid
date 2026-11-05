# frozen_string_literal: true

module Pubid
  module Cie
    # The pubid-scheme URN of CIE (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   CIE S 004/E-2001  ->
    #   urn:pubid:cie:std:004:style-legacy:year-2001:f:0.sp-true:…
    #
    # The current urn:cie:… form of #to_urn is pubid-invented and stays
    # there. `s_prefix`/`d_prefix` (the leading `S`/`D` token) and the part
    # separator are spelling-only, so they are facets; `style` names how the
    # designation reads and is an atom. A bundle's members are the `ids`
    # list; its base document shares the slug prefix.
    PubidUrnSchema = Pubid::PubidUrn.define("cie") do
      atom "copublisher", "co"
      atom "part", "part"
      atom "year", "year"
      atom "stage", "stage"
      atom "language.code", "lang"
      atom "language.format", "langformat"
      atom "language.translation_year", "transyear"
      atom "amendment_number", "amendmentnumber"
      atom "conference", "conference"
      atom "doc_type", "doctype"
      atom "iec_identifier", "iecidentifier"
      atom "iso_reference", "isoreference"
      atom "iteration", "iter"
      atom "page", "page"
      atom "style", "style"
      atom "variant", "variant"
      atom "ids", "ids", kind: :ids

      facet "s_prefix", "sp", kind: :bool
      facet "part_separator", "partsep"
      facet "d_prefix", "dp", kind: :bool

      type "pubid:cie:bundle", "bundle"
      type "pubid:cie:conference", "c"
      type "pubid:cie:corrigendum", "cor"
      type "pubid:cie:dual-published", "dp"
      type "pubid:cie:identical", "i"
      type "pubid:cie:identifier", "id"
      type "pubid:cie:joint-published", "jp"
      type "pubid:cie:proceedings", "p"
      type "pubid:cie:standard", "std"
      type "pubid:cie:supplement", "sup"
      type "pubid:cie:tutorial-bundle", "tb"
    end
  end
end
