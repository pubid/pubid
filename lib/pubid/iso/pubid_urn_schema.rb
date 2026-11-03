# frozen_string_literal: true

module Pubid
  module Iso
    # The pubid-scheme URN of ISO (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   ISO/IEC 13818-1:2015/Amd 3:2016
    #   urn:pubid:iso:is:13818:co-IEC:part-1:year-2015:amd:3:co-IEC:year-2016
    #
    # The type tokens follow the RFC 5141 type codes where one exists. The
    # core is the document number; every other value is an optional prefixed
    # atom, in the order below. The official urn:iso:std: form stays on
    # #to_urn (Pubid::Iso::UrnGenerator).
    PubidUrnSchema = Pubid::PubidUrn.define("iso") do
      atom "publisher", "pub"
      atom "copublishers", "co", kind: :list
      atom "part", "part"
      atom "subpart", "subpart"
      atom "year", "year"
      atom "month", "month"
      atom "day", "day"
      atom "undated", "undated", kind: :bool
      atom "edition.number", "ed"
      atom "stage", "stage"
      atom "stage_iteration", "iter"
      atom "supplement_version", "v"
      atom "languages.*.code", "lang"
      atom "locality.value", "loc"

      facet "languages.*.original_code", "langsrc"
      facet "edition.original_text", "edsrc"

      type "pubid:iso:international-standard", "is"
      type "pubid:iso:technical-report", "tr"
      type "pubid:iso:technical-specification", "ts"
      type "pubid:iso:guide", "guide"
      type "pubid:iso:pas", "pas"
      type "pubid:iso:recommendation", "r"
      type "pubid:iso:international-standardized-profile", "isp"
      type "pubid:iso:international-workshop-agreement", "iwa"
      type "pubid:iso:technology-trends-assessments", "tta"
      type "pubid:iso:data", "data"
      type "pubid:iso:tc-document", "tcdoc",
           atoms: [%w[tc_type tctype], %w[tc_number tc],
                   %w[sc_type sctype], %w[sc_number sc],
                   %w[wg_type wgtype], %w[wg_number wg]]
      type "pubid:iso:directives", "dir", atoms: [%w[subgroup subgroup]]
      type "pubid:iso:directives-supplement", "dirsup"

      type "pubid:iso:amendment", "amd"
      type "pubid:iso:corrigendum", "cor"
      type "pubid:iso:addendum", "add"
      type "pubid:iso:extract", "ext"
      type "pubid:iso:supplement", "sup"

      type "pubid:iso:all-parts", "all", atoms: [["identifiers", "ids", :ids]]
      type "pubid:iso:bundled-identifier", "bundle",
           atoms: [["supplements", "sups", :ids]]
    end
  end
end
