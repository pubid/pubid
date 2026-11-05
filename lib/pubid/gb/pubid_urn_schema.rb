# frozen_string_literal: true

module Pubid
  module Gb
    # The pubid-scheme URN of GB (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   JB/T 13368-2018  ->  urn:pubid:gb:std:13368:pub-JB:mandate-T:year-2018
    #
    # The publisher and the mandate letter (`T` of GB/T) are atoms. The
    # current urn:gb:… form of #to_urn is pubid-invented and stays there.
    PubidUrnSchema = Pubid::PubidUrn.define("gb") do
      atom "publisher", "pub"
      atom "part", "part"
      atom "year", "year"
      atom "mandate", "mandate"
      atom "identifiers", "ids", kind: :ids

      type "pubid:gb:all-parts", "all", atoms: []
      type "pubid:gb:identifier", "id"
      type "pubid:gb:standard", "std"
    end
  end
end
