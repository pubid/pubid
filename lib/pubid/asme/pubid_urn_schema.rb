# frozen_string_literal: true

module Pubid
  module Asme
    # The pubid-scheme URN of ASME (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   ASME B30.3-20XX (Revision of ASME B30.1-2020)
    #   urn:pubid:asme:std:B30.3:pub-ASME:draftyear-20XX
    #     :parentheticalrevision-...
    #
    # The number is the core; the atoms follow the doc's canonical order.
    # +parenthetical_revision+ and +revision_note+ are the two verbatim
    # bracket notes, case-kept.
    PubidUrnSchema = Pubid::PubidUrn.define("asme") do
      atom "publisher", "pub"
      atom "year", "year"
      atom "language", "lang"
      atom "csa_number", "csanumber"
      atom "draft_year", "draftyear"
      atom "first_code", "firstcode"
      atom "first_publisher", "firstpublisher"
      atom "handbook", "handbook", kind: :bool
      atom "joint_publisher", "jointpublisher"
      atom "parenthetical_revision", "parentheticalrevision"
      atom "ptc_suffix", "ptcsuffix"
      atom "revision_note", "revisionnote"
      atom "second_publisher", "secondpublisher"

      type "pubid:asme:base", "base"
      type "pubid:asme:identifier", "id"
      type "pubid:asme:standard", "std"
    end
  end
end
