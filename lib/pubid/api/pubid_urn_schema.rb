# frozen_string_literal: true

module Pubid
  module Api
    # The pubid-scheme URN of API (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   API MPMS Ch. 10.10  ->  urn:pubid:api:mpms:10.10:subsec-...
    #
    # The number is the core of every type; +part+, +section+ and
    # +subsection+ are atoms, in the doc's canonical order.
    PubidUrnSchema = Pubid::PubidUrn.define("api") do
      atom "part", "part"
      atom "section", "section"
      atom "subsection", "subsection"

      type "pubid:api:base", "base"
      type "pubid:api:bulletin", "bulletin"
      type "pubid:api:continuous-operations-standard", "cos"
      type "pubid:api:identifier", "id"
      type "pubid:api:mpms", "mpms"
      type "pubid:api:publication", "pub"
      type "pubid:api:recommended-practice", "rp"
      type "pubid:api:specification", "spec"
      type "pubid:api:standard", "std"
      type "pubid:api:technical-report", "tr"
      type "pubid:api:typeless-standard", "ts"
    end
  end
end
