# frozen_string_literal: true

module Pubid
  module Sae
    # The pubid-scheme URN of SAE (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   SAE J3016_202104  ->  urn:pubid:sae:id:3016:typeabbr-J:year-2021:month-4
    #
    # The current urn:sae:… form of #to_urn is pubid-invented and stays
    # there. The type (`J`, `AS`, `ARP`, `AMS`) is an atom, because the
    # identifier type is one class carrying every series code; the date
    # fields are Integers.
    PubidUrnSchema = Pubid::PubidUrn.define("sae") do
      atom "type.abbr", "typeabbr"
      atom "revision", "rev"
      atom "amendment", "amd"
      atom "date.year", "year", kind: :int
      atom "date.month", "month", kind: :int

      type "pubid:sae:identifier", "id"
    end
  end
end
