# frozen_string_literal: true

module Pubid
  module Iho
    # The pubid-scheme URN of IHO (issue #670; the flavor's own urn
    # scheme notes, lib/pubid/iho/urn.adoc).
    #
    #   IHO S-100 5.0.0 Part 2 (2024)  ->
    #   urn:pubid:iho:std:100:ed-5.0.0:year-2024:part-2
    #   IHO S-158:102 1.0.0            ->
    #   urn:pubid:iho:std:158:product-102:ed-1.0.0
    #
    # The atoms follow the containment order of the official URN: the
    # S-158 member designator rides the document code (the product
    # component is the series member itself — `product-<NNN>`, issue
    # #774), then the document's edition and year, then each component
    # with its own edition/year right after it — supplement, part,
    # annex, appendix (the two-level Appendix D-2 keeps the subnumber as
    # its own atom), volume (the unified locator, yearbook volumes
    # included: `vol-2024`), issue. The S-4 spec citation sits inside
    # its part (`spec-`, `specsub-`, `specvar-`). Letters stay
    # case-preserved (`part-A`). The legacy `y.` yearbook marker is
    # decodable in the official URN parser, never emitted here: a
    # periodical has no `year-` atom value, its volume carries the year.
    # The official URN of the S/P/M series is the adopted IHO MRN
    # guidance form (`urn:mrn:iho:pub:spec:...`, UrnGenerator) — this
    # scheme is pubid's own and is not governed by the guidance.
    PubidUrnSchema = Pubid::PubidUrn.define("iho") do
      # The S-158 series member (issue #774): rides the document code,
      # before the edition — `urn:pubid:iho:std:158:product-102:ed-1.0.0`.
      atom "product", "product"
      atom "edition", "ed"
      atom "year", "year"
      atom "supplement", "sup"
      atom "supplement_edition", "suped"
      atom "supplement_year", "supyear"
      atom "part", "part"
      atom "part_edition", "parted"
      atom "part_year", "party"
      # The S-4 loose-leaf spec citation (issue #691): a child of the
      # part (the citation letter rides `part-`); the section is
      # derivable from the spec's hundreds digit — never an atom.
      atom "spec", "spec"
      atom "spec_sub", "specsub"
      atom "spec_variant", "specvar"
      atom "annex", "annex"
      atom "annex_edition", "anned"
      atom "annex_year", "annyear"
      atom "appendix", "appendix"
      atom "appendix_subnumber", "appsub"
      atom "appendix_edition", "apped"
      atom "appendix_year", "appyear"
      atom "volume", "vol"
      atom "issue", "issue"
      atom "volume_edition", "voled"
      atom "volume_year", "voly"

      type "pubid:iho:bibliographic", "b"
      type "pubid:iho:circular-letter", "cl"
      type "pubid:iho:identifier", "id"
      type "pubid:iho:miscellaneous", "m"
      type "pubid:iho:publication", "pub"
      type "pubid:iho:standard", "std"
    end
  end
end
