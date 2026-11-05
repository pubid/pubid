# frozen_string_literal: true

module Pubid
  module Csa
    # The pubid-scheme URN of CSA (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   CAN/CSA-A123.2-03 (R2023)  ->
    #   urn:pubid:csa:ca:A123.2:year-2003:f:0.yearformat-dash:…
    #
    # The current urn:csa:… form of #to_urn is pubid-invented and stays
    # there. The spelling/format cluster of the CSA year (`year_format`,
    # `year_prefix`, the publisher prefix it is printed with, the
    # original-digit spellings of a reaffirmation, the French marker) is
    # facets — the same document prints two ways; everything else is an
    # atom. A combined identifier carries its members in `identifiers`, a
    # bundled one in `bundled_with` (both bracketed lists); the adopted
    # document goes along +base+ and keeps its own flavor's schema.
    PubidUrnSchema = Pubid::PubidUrn.define("csa") do
      atom "publisher", "pub"
      atom "part", "part"
      atom "subpart", "subpart"
      atom "copublishers", "co", kind: :list
      atom "series", "series", kind: :bool
      atom "year", "year"
      atom "reaffirmation", "reaff"
      atom "cec_part", "cecpart"
      atom "code_only", "codeonly", kind: :bool
      atom "materials_after_keyword", "materialsafterkeyword", kind: :bool
      atom "no_number", "nonumber"
      atom "package_keyword", "packagekeyword"
      atom "package_materials", "packagematerials"
      atom "identifiers", "ids", kind: :ids
      atom "bundled_with", "bundledwith", kind: :ids

      facet "year_format", "yearformat"
      facet "year_prefix", "yearprefix"
      facet "publisher_prefix", "pubprefix"
      facet "has_publisher", "haspublisher", kind: :bool
      facet "original_reaffirmation_4digit", "origreaff4", kind: :bool
      facet "original_year_4digit", "origyear4", kind: :bool
      facet "separator", "separator"
      facet "series_prefix", "seriesprefix"
      facet "french", "french", kind: :bool

      type "pubid:csa:amendment", "amd"
      type "pubid:csa:base", "base"
      type "pubid:csa:bundled", "bundled"
      type "pubid:csa:canadian-adopted", "ca"
      type "pubid:csa:cec", "cec"
      type "pubid:csa:combined", "combined"
      type "pubid:csa:csa-adopted", "ca2"
      type "pubid:csa:identifier", "id"
      type "pubid:csa:package", "package"
      type "pubid:csa:series", "series"
      type "pubid:csa:standard", "std"
    end
  end
end
