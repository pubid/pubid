# frozen_string_literal: true

module Pubid
  module Ashrae
    # The pubid-scheme URN of ASHRAE (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   ASHRAE Standard 15-2007 (RA 2010)
    #   urn:pubid:ashrae:std:15:year-2007:reaffirmed-2010
    #
    # The number is the core of every type (the base-anchored ones emit
    # it as NULL when absent — the errata and the package carry their
    # identity in the base chain). The atoms follow the doc's canonical
    # order; the date internals stay placed until the Components::Code
    # reduction lands (docs/URN-SCHEMES.adoc, ashrae finding).
    PubidUrnSchema = Pubid::PubidUrn.define("ashrae") do
      atom "copublisher", "co"
      atom "year", "year"
      atom "date.day", "dateday"
      atom "date.month", "datemonth"
      atom "date.year", "dateyear"
      atom "addendum_code", "addendumcode"
      atom "addendum_codes", "addendumcodes"
      atom "package_description", "packagedescription"
      atom "reaffirmed", "reaffirmed"
      atom "suffix", "suffix"

      type "pubid:ashrae:addenda-package", "ap"
      type "pubid:ashrae:addendum", "add"
      type "pubid:ashrae:combined-addenda", "ca"
      type "pubid:ashrae:errata", "err"
      type "pubid:ashrae:guideline", "g"
      type "pubid:ashrae:identifier", "id"
      type "pubid:ashrae:interpretation", "interp"
      type "pubid:ashrae:standard", "std"
    end
  end
end
