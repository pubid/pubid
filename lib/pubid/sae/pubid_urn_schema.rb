# frozen_string_literal: true

module Pubid
  module Sae
    # The pubid-scheme URN of SAE (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   SAE J3016_202104   ->  urn:pubid:sae:id:3016:typeabbr-J:year-2021:month-4
    #   SAE ARP4754A:2010  ->  urn:pubid:sae:id:4754:typeabbr-ARP:rev-A:yearflat-2010
    #
    # The current urn:sae:… form of #to_urn is pubid-invented and stays
    # there. The type (`J`, `AS`, `ARP`, `AMS`) is an atom, because the
    # identifier type is one class carrying every series code; the date
    # fields are Integers.
    #
    # SAE's hash carries two date shapes (the canonical flattening keeps a
    # year-alone date flat: pubid#360), so a year gets one prefix per shape
    # — the ashrae ruling. `year-` stays the nested year+month form the
    # first release emitted; `yearflat-` is the flat year-alone form the
    # corpus round (pubid#669) added. A part is top-level in the hash
    # (AMS-QQ-A-250/4B -> part-4).
    PubidUrnSchema = Pubid::PubidUrn.define("sae") do
      atom "type.abbr", "typeabbr"
      atom "revision", "rev"
      atom "amendment", "amd"
      atom "part", "part"
      atom "date.year", "year", kind: :int
      atom "date.month", "month", kind: :int
      atom "year", "yearflat"

      type "pubid:sae:identifier", "id"
    end
  end
end
