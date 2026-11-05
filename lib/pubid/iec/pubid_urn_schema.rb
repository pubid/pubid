# frozen_string_literal: true

module Pubid
  module Iec
    # The pubid-scheme URN of IEC (issue #670 completes the flavor;
    # docs/URN-SCHEMES.adoc).
    #
    #   CISPR 12:2007/AMD1:2009  ->
    #   urn:pubid:iec:is:12:pub-CISPR:year-2007:amd:1:year-2009
    #
    # The partial schema landed with IEEE named the one type IEEE nests; the
    # GOST wave added the TS, TR, amendment and consolidated identifier a
    # GOST adoption can name. This wave declares the rest of the flavor and
    # the atoms its types serialize (`vap`, the sheet/fragment numbers);
    # every new atom sits after the ones earlier waves placed, so the
    # published URNs are unchanged. `database` was a string atom before any
    # URN carried it — the corpus holds only `true`, so it is a bool.
    #
    # Known identity gaps the URN inherits, because it carries exactly what
    # to_hash carries (pinned in lib/pubid/iec/CLAUDE.md): a WorkingDocument
    # serializes only `_type`, and a TestReportForm's CISPR document sits in
    # the unserialized `cispr_identifier` — such rows emit type-only URNs
    # (`urn:pubid:iec:wd`) and are one hash, so they are not a collision.
    # Mapping them is a wire-format change and stays the separate decision
    # it already was. The official RFC 5141-style urn:iec:std: form stays
    # on #to_urn.
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
      atom "database", "database", kind: :bool
      atom "fragment_number", "frag"
      atom "sheet_number", "sheet"
      atom "sheet_year", "sheetyear"
      atom "vap", "vap", kind: :list
      atom "languages.*.code", "lang"
      atom "identifiers", "ids", kind: :ids

      facet "languages.*.original_code", "langsrc"

      type "pubid:iec:all-parts", "all"
      type "pubid:iec:amendment", "amd"
      type "pubid:iec:base", "base"
      type "pubid:iec:component-specification", "cs"
      type "pubid:iec:conformity-assessment", "ca"
      type "pubid:iec:consolidated-identifier", "consol", core: []
      type "pubid:iec:corrigendum", "cor"
      type "pubid:iec:fragment-identifier", "fi", core: []
      type "pubid:iec:guide", "guide"
      type "pubid:iec:identifier", "id"
      type "pubid:iec:international-standard", "is"
      type "pubid:iec:interpretation-sheet", "is2"
      type "pubid:iec:operational-document", "od"
      type "pubid:iec:publicly-available-specification", "pas"
      type "pubid:iec:sheet-identifier", "si", core: []
      type "pubid:iec:single-identifier", "si2"
      type "pubid:iec:societal-technology-trend-report", "sttr"
      type "pubid:iec:systems-reference-document", "srd"
      type "pubid:iec:technical-group", "tg"
      type "pubid:iec:technical-report", "tr"
      type "pubid:iec:technical-specification", "ts"
      type "pubid:iec:technology-report", "tr2"
      type "pubid:iec:test-report-form", "trf"
      type "pubid:iec:vap-identifier", "vi"
      type "pubid:iec:white-paper", "wp"
      type "pubid:iec:working-document", "wd"
    end
  end
end
