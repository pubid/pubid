# frozen_string_literal: true

module Pubid
  module W3c
    # The pubid-scheme URN of w3c (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("w3c") do
      atom "date", "date"


      type "pubid:w3c:candidate-recommendation", "cr"
      type "pubid:w3c:candidate-recommendation-draft", "crd"
      type "pubid:w3c:draft-note", "dn"
      type "pubid:w3c:identifier", "id"
      type "pubid:w3c:note", "note"
      type "pubid:w3c:obsolete-recommendation", "or"
      type "pubid:w3c:proposed-edited-recommendation", "per"
      type "pubid:w3c:proposed-recommendation", "pr"
      type "pubid:w3c:recommendation", "rec"
      type "pubid:w3c:standard", "std"
      type "pubid:w3c:superseded-recommendation", "sr"
      type "pubid:w3c:working-draft", "wd"
    end
  end
end
