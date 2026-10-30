# frozen_string_literal: true

module Pubid
  module Omg
    # Grammar for OMG specification identifiers.
    #
    # Accepts:
    #   OMG {ACRONYM}[ {VERSION}][ {PART}]
    #
    # ACRONYM is the URL segment of https://www.omg.org/spec/<ACRONYM>/, e.g.
    # "UML", "DDS-XTypes", "EDMC-FIBO/BE", "VSIPL++", "smartant".
    # VERSION is digits/dots, optionally followed by a beta label, e.g. "1.0",
    # "2.5.1", "5 beta 3", "2.5 beta".
    # PART is the volume or format segment, e.g. "Superstructure", "PDF". A
    # space or a slash separates it.
    class Parser
    end
  end
end
