# frozen_string_literal: true

module Pubid
  module Iho
    # The pubid-scheme URN of IHO (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   IHO S-100 5.0.0 Part 2 (2024)  ->
    #   urn:pubid:iho:std:100:ed-5.0.0:year-2024:part-2
    #
    # The atoms follow the containment order of the official URN
    # (urn:iho:s:100:ed-5.2.0:part-2, Pubid::Iho::UrnGenerator): the
    # document's edition and year first, then each component with its own
    # edition/year right after it — supplement, part, annex, appendix (the
    # two-level Appendix D-2 keeps the subnumber as its own atom), volume
    # (the unified locator, yearbook volumes included: `vol-2024`), issue.
    # Letters stay case-preserved (`part-A`). The legacy `y.` yearbook
    # marker is decodable in the official URN parser, never emitted here:
    # a periodical has no `year-` atom value, its volume carries the year.
    # The official urn:mrn:iho:… form stays on #to_urn.
    PubidUrnSchema = Pubid::PubidUrn.define("iho") do
      atom "edition", "ed"
      atom "year", "year"
      atom "supplement", "sup"
      atom "supplement_edition", "suped"
      atom "supplement_year", "supyear"
      atom "part", "part"
      atom "part_edition", "parted"
      atom "part_year", "party"
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
