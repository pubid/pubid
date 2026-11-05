# frozen_string_literal: true

module Pubid
  module Iala
    # The pubid-scheme URN of iala (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("iala") do
      atom "edition", "ed"
      atom "language", "lang"
      atom "annex_form", "annexform"
      atom "letter", "letter"


      type "pubid:iala:advice", "advice"
      type "pubid:iala:annex", "annex"
      type "pubid:iala:general-assembly", "ga"
      type "pubid:iala:guideline", "g"
      type "pubid:iala:identifier", "id"
      type "pubid:iala:letter", "letter"
      type "pubid:iala:manual", "manual"
      type "pubid:iala:model-course", "mc"
      type "pubid:iala:recommendation", "rec"
      type "pubid:iala:report", "rpt"
      type "pubid:iala:resolution", "r"
      type "pubid:iala:standard", "std"
    end
  end
end
