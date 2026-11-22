# frozen_string_literal: true

module Pubid
  module Wmo
    # The pubid-scheme URN of wmo (pubid#763 widened;
    # docs/URN-SCHEMES.adoc).
    #
    #   WMO-No. 1364, 2025 edition  ->  urn:pubid:wmo:pub:1364:ed-2025
    #   WMO/TD-No. 196              ->  urn:pubid:wmo:pub:196:series-TD
    #   WMO-No. 306, Volume I.1     ->  urn:pubid:wmo:pub:306:vol-I.1
    #   WMO-No. 8, 2021/2018 edition
    #                               ->  urn:pubid:wmo:pub:8:ed-2021~2F2018
    #   WMO-No. 8, Provisional 2026 edition
    #                               ->  urn:pubid:wmo:pub:8:ed-2026:
    #                                   status-Provisional
    #   WMO-No. 1364, 2023 edition, updated in 2025
    #                               ->  urn:pubid:wmo:pub:1364:ed-2023:
    #                                   updated-2025
    #   S-411 1.2.1                 ->  urn:pubid:wmo:std:411:ed-1.2.1
    #   S-411 Annex A  ->  urn:pubid:wmo:std:411:annex:annexform-Annex:letter-A
    #
    # The edition is one atom: a calendar-year face (the year pair
    # escaped `~2F` for its slash) on a publication, a dotted face on a
    # standard or annex. The series, volume, status and updated-in
    # faces are atoms of the widening; series is nil on the WMO-No.
    # default, so existing URNs are unchanged. The annex marker and
    # letter follow the iala schema (annexform- / letter-).
    PubidUrnSchema = Pubid::PubidUrn.define("wmo") do
      atom "series", "series"
      atom "volume", "vol"
      atom "edition", "ed"
      atom "edition_status", "status"
      atom "updated_in", "updated"
      atom "annex_form", "annexform"
      atom "letter", "letter"

      type "pubid:wmo:publication", "pub"
      type "pubid:wmo:standard", "std"
      type "pubid:wmo:annex", "annex"
    end
  end
end
