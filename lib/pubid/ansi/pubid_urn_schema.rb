# frozen_string_literal: true

module Pubid
  module Ansi
    # The pubid-scheme URN of ANSI (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   ANSI 802.3-2012
    #   urn:pubid:ansi:std:802.3:pub-ANSI:year-2012:f:0.datesep--
    #
    # Landed with the IEEE wave, which nests ANSI ids ("IEEE Std 144-1971
    # (ANSI C37.24-1971)"). The trailing "-2012" is the year (relaton#45);
    # its dash is the spelling facet +datesep+.
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
      atom "revision", "rev"
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
      facet "date_separator", "datesep"
      facet "number_separator", "numsep"

      type "pubid:ansi:standard", "std"
      type "pubid:ansi:american-national-standard", "ans"
      type "pubid:ansi:identifier", "id"
    end
  end
end
