# frozen_string_literal: true

module Pubid
  module Bipm
    # The pubid-scheme URN of BIPM (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   CCTF REC 2 (2012, E)  ->
    #   urn:pubid:bipm:cd:2:group-CCTF:typecode-REC:year-2012:lang-E
    #
    # The current urn:bipm:… form of #to_urn is pubid-invented (the
    # deviations from the JCGM 200:2012 URN pattern are owner-pinned in
    # lib/pubid/bipm/CLAUDE.md) and stays there; this schema reads #to_hash
    # only, so no codec deviation knob was needed. Years are Integers.
    PubidUrnSchema = Pubid::PubidUrn.define("bipm") do
      atom "part", "part"
      atom "issue", "issue"
      atom "year", "year", kind: :int
      atom "edition", "ed"
      atom "version", "v"
      atom "appendix", "appendix"
      atom "annex", "annex"
      atom "language", "lang"
      atom "article", "article"
      atom "form", "form"
      atom "group", "group"
      atom "guide_kind", "guidekind"
      atom "mep_code", "mepcode"
      atom "report_code", "reportcode"
      atom "type_code", "typecode"
      atom "variant", "variant"
      atom "years", "years"

      type "pubid:bipm:committee-document", "cd"
      type "pubid:bipm:guide", "guide"
      type "pubid:bipm:identifier", "id"
      type "pubid:bipm:meeting", "meeting"
      type "pubid:bipm:mep", "mep"
      type "pubid:bipm:metrologia-article", "ma"
      type "pubid:bipm:si-brochure", "sb"
    end
  end
end
