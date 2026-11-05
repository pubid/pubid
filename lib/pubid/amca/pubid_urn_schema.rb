# frozen_string_literal: true

module Pubid
  module Amca
    # The pubid-scheme URN of AMCA (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   ANSI/AMCA 210-16 /ASHRAE 51-16  ->
    #   urn:pubid:amca:std:210:co-ASHRAE:year-16
    #
    # The current urn:amca:… form of #to_urn is pubid-invented and stays
    # there.
    PubidUrnSchema = Pubid::PubidUrn.define("amca") do
      atom "copublisher", "co"
      atom "year", "year"
      atom "revision", "rev"
      atom "reaffirmed", "reaffirmed"
      atom "interpretation_code", "interpcode"

      type "pubid:amca:identifier", "id"
      type "pubid:amca:interpretation", "interp"
      type "pubid:amca:publication", "pub"
      type "pubid:amca:standard", "std"
    end
  end
end
