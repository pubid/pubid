# frozen_string_literal: true

require "parslet"

module Pubid
  module Evs
    # Grammar for the printed EVS national-adoption reference, composed with
    # the CEN/CENELEC parser as an embedded atom (the same pattern ISO uses
    # for IDF joint identifiers, and IEEE for AIEE/IRE/NESC):
    #
    #   "EVS" ("-" | " ") <CEN identifier>
    #
    # The adopted portion is parsed by the real CEN grammar — publisher,
    # adopted org, number, parts, year, supplements, edition — and captured
    # as a structured :adopted subtree for the CEN builder.
    #
    #   "EVS-EN 18216:2026"            → {evs_separator, adopted: {publisher, number, year}}
    #   "EVS-EN ISO 9001:2015/A1:2024" → {evs_separator, adopted: {publisher, adopted_string, supplements}}
    class Parser < ::Pubid::Parser::Grammar
      rule(:root) do
        str("EVS") >>
          (str("-") | str(" ")).as(:evs_separator) >>
          ::Pubid::CenCenelec::Parser.new.identifier.as(:adopted)
      end
    end
  end
end
