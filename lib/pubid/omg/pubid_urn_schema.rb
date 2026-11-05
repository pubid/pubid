# frozen_string_literal: true

module Pubid
  module Omg
    # The pubid-scheme URN of OMG (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   OMG AMI4CCM 1.0  ->  urn:pubid:omg:spec:acronym-AMI4CCM:v-1.0
    #
    # No positional core: an OMG specification names itself by its acronym.
    # The current urn:omg:… form of #to_urn is pubid-invented and stays
    # there.
    PubidUrnSchema = Pubid::PubidUrn.define("omg") do
      atom "part", "part"
      atom "version", "v"
      atom "acronym", "acronym"

      type "pubid:omg:identifier", "id", core: []
      type "pubid:omg:specification", "spec", core: []
    end
  end
end
