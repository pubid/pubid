# frozen_string_literal: true

module Pubid
  module Un
    # The pubid-scheme URN of UN (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   A/RES/78/1  ->  urn:pubid:un:document:A,RES,78:1
    #
    # The path segments are the list before the final number; the number is
    # the positional core. The current urn:un:… form of #to_urn is
    # pubid-invented and stays there.
    PubidUrnSchema = Pubid::PubidUrn.define("un") do
      atom "path", "path", kind: :list

      type "pubid:un:document", "document"
      type "pubid:un:identifier", "id"
    end
  end
end
