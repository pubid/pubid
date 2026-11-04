# frozen_string_literal: true

module Pubid
  module Jcgm
    # The pubid-scheme URN of JCGM (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   JCGM 100:2008/Amd 1:2026
    #   urn:pubid:jcgm:guide:100:year-2008:lang-en:amd:1:year-2026
    #
    # The number is the core of every type; the year, the month/day of a
    # dated meeting or amendment and the languages are atoms, in the
    # doc's canonical order. The original language code is a facet.
    PubidUrnSchema = Pubid::PubidUrn.define("jcgm") do
      atom "year", "year"
      atom "month", "month"
      atom "day", "day"
      atom "languages.*.code", "lang"

      facet "languages.*.original_code", "langsrc"

      type "pubid:jcgm:amendment", "amd"
      type "pubid:jcgm:corrigendum", "cor"
      type "pubid:jcgm:guide", "guide"
      type "pubid:jcgm:gum-guide", "gumguide"
      type "pubid:jcgm:identifier", "id"
      type "pubid:jcgm:meeting", "meeting"
    end
  end
end
