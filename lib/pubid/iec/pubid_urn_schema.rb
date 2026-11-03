# frozen_string_literal: true

module Pubid
  module Iec
    # The pubid-scheme URN of IEC — PARTIAL (issue #656;
    # docs/URN-SCHEMES.adoc).
    #
    # Only +pubid:iec:international-standard+ is declared, because IEEE
    # identifiers nest it (IEC/IEEE co-publications). IEC's own wave declares
    # the rest of the flavor; until then IEC stays pending in the contract
    # spec. The official RFC 5141-style urn:iec:std: form stays on #to_urn.
    PubidUrnSchema = Pubid::PubidUrn.define("iec") do
      atom "publisher", "pub"
      atom "copublishers", "co", kind: :list
      atom "part", "part"
      atom "subpart", "subpart"
      atom "year", "year"
      atom "month", "month"
      atom "day", "day"
      atom "undated", "undated", kind: :bool
      atom "edition", "ed"
      atom "stage", "stage"
      atom "stage_iteration", "iter"
      atom "database", "database"
      atom "languages.*.code", "lang"

      facet "languages.*.original_code", "langsrc"

      type "pubid:iec:international-standard", "is"
    end
  end
end
