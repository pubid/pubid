# frozen_string_literal: true

module Pubid
  module Eu
    # The pubid-scheme URN of EU legal acts (docs/URN-SCHEMES.adoc, [[urn-eu]]).
    #
    #   EU Regulation 1227/2011  ->  urn:pubid:eu:reg:2011:1227
    #   EU Decision 1082/2013  ->
    #     urn:pubid:eu:dec:2013:1082:f:0.numberfirst-true
    #
    # Every act has a year and a number, so both are the positional core,
    # year first (the CELEX and ELI order). The legal family is an atom; the
    # number-order flag records only the spelling, so it is a facet.
    PubidUrnSchema = Pubid::PubidUrn.define("eu") do
      atom "family", "family"
      facet "number_first", "numberfirst", kind: :bool

      type "pubid:eu:regulation", "reg", core: %w[year number]
      type "pubid:eu:directive", "dir", core: %w[year number]
      type "pubid:eu:decision", "dec", core: %w[year number]
    end
  end
end
