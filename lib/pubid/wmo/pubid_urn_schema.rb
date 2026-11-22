# frozen_string_literal: true

module Pubid
  module Wmo
    # The pubid-scheme URN of wmo (pubid#763; docs/URN-SCHEMES.adoc).
    #
    #   WMO-No. 1364, 2025 edition  ->  urn:pubid:wmo:pub:1364:ed-2025
    #   S-411 1.2.1                 ->  urn:pubid:wmo:std:411:ed-1.2.1
    #   S-411 Annex A  ->  urn:pubid:wmo:std:411:annex:annexform-Annex:letter-A
    #
    # The edition is one atom: a calendar-year face on a publication,
    # a dotted face on a standard or annex. The annex marker and letter
    # follow the iala schema (annexform- / letter-).
    PubidUrnSchema = Pubid::PubidUrn.define("wmo") do
      atom "edition", "ed"
      atom "annex_form", "annexform"
      atom "letter", "letter"

      type "pubid:wmo:publication", "pub"
      type "pubid:wmo:standard", "std"
      type "pubid:wmo:annex", "annex"
    end
  end
end
