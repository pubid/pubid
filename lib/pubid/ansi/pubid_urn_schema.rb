# frozen_string_literal: true

module Pubid
  module Ansi
    # The pubid-scheme URN of ANSI (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   ANSI 802.3-2012
    #   urn:pubid:ansi:std:802.3:pub-ANSI:part-2012
    #
    # Landed with the IEEE wave, which nests ANSI ids ("IEEE Std 144-1971
    # (ANSI C37.24-1971)"). Note that ANSI stores the year of
    # "ANSI 802.3-2012" in +part+ ("2012"); the URN keeps it as it is.
    #
    # A component attribute maps through its identifying field only
    # (+type.abbr+, +stage.abbr+, +edition.number+ …). The registry fields of
    # a stage or a type (+name+, +harmonized_stages+) are deliberately not
    # placed, so a value there makes #to_pubid_urn raise rather than write
    # registry data into the URN. The corpus sets none of them.
    PubidUrnSchema = Pubid::PubidUrn.define("ansi") do
      atom "publisher.body", "pub"
      atom "copublishers.*.body", "co"
      atom "type.abbr", "type"
      atom "part", "part"
      atom "subpart", "subpart"
      atom "year", "year"
      atom "date.year", "dateyear"
      atom "date.month", "datemonth"
      atom "date.day", "dateday"
      atom "date.undated", "undated", kind: :bool
      atom "edition.number", "ed"
      atom "stage.abbr", "stage"
      atom "stage_iteration.number", "iter"
      atom "languages.*.code", "lang"
      atom "locality.value", "loc"

      facet "languages.*.original_code", "langsrc"
      facet "edition.original_text", "edsrc"

      type "pubid:ansi:standard", "std"
      type "pubid:ansi:american-national-standard", "ans"
      type "pubid:ansi:identifier", "id"
    end
  end
end
