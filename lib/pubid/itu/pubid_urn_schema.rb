# frozen_string_literal: true

module Pubid
  module Itu
    # The pubid-scheme URN of ITU (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   ITU-T G.729 Annex B (1996) Cor. 3 (03/2001)
    #   urn:pubid:itu:rec:729:sector-T:series-G:anx:B:year-1996:
    #     cor:3:year-2001:month-03
    #
    # The nodes go root first along +base+, so every supplement, annex and
    # appendix of a Recommendation shares its slug prefix. The official
    # urn:itu: form (IANA-registered) stays on #to_urn.
    #
    # Facets are the flags the ITU classes call rendering-only: the same
    # document printed two ways ("Suppl.1" and "Suppl. 1", "V.25 ter" and
    # "V.25ter", "D.502R" and "D.502 R", "Amd. 1/Cor. 1" and "Amd. 1 Cor. 1").
    # Every other flag is an atom, because it names a different document
    # ("Technical Cor.", "attachment", the word "series").
    #
    # Not placed, so #to_pubid_urn raises rather than drop it: the +parts+ of
    # a combined designation ("G.780-1/Y.1351-2"), a list inside a list. No
    # pass fixture has one.
    PubidUrnSchema = Pubid::PubidUrn.define("itu") do
      atom "sector", "sector"
      atom "series", "series"
      atom "series_word", "seriesword", kind: :bool
      atom "series_dash", "seriesdash", kind: :bool
      atom "imp_marker", "imp"
      atom "subseries", "subseries"
      atom "parts", "part", kind: :list
      atom "series_suffix", "suffix"
      atom "qualifier", "qualifier"
      atom "range_end", "rangeend"
      atom "attachment", "attachment", kind: :bool
      atom "combined.*.series", "combseries"
      atom "combined.*.number", "combnumber"
      atom "combined.*.subseries", "combsubseries"
      atom "combined.*.series_suffix", "combsuffix"
      atom "combined.*.qualifier", "combqualifier"
      atom "study_group", "sg"
      atom "has_bl", "bl", kind: :bool
      atom "bracketed", "bracketed", kind: :bool
      atom "has_colon", "colon", kind: :bool
      atom "technical", "technical", kind: :bool
      atom "material", "material"
      atom "version", "v"
      atom "year", "year"
      atom "month", "month"
      atom "day", "day"
      atom "language", "lang"
      atom "common_text_twin", "twin", kind: :id

      facet "series_suffix_spaced", "suffixspaced", kind: :bool
      facet "qualifier_glued", "qualifierglued", kind: :bool
      facet "combined.*.series_suffix_spaced", "combsuffixspaced",
            kind: :bools
      facet "combined.*.qualifier_glued", "combqualifierglued", kind: :bools
      facet "number_glued", "numberglued", kind: :bool
      facet "slash_joined", "slashjoined", kind: :bool

      type "pubid:itu:recommendation", "rec"
      type "pubid:itu:report", "rpt"
      type "pubid:itu:combined-identifier", "comb"
      type "pubid:itu:question", "q"
      type "pubid:itu:handbook", "hb"
      type "pubid:itu:radio-regulations", "rr"
      type "pubid:itu:special-publication", "sp"
      type "pubid:itu:contribution", "c"
      type "pubid:itu:identifier", "id"

      type "pubid:itu:annex", "annex"
      type "pubid:itu:annex-of-recommendation", "anx"
      type "pubid:itu:appendix-of-recommendation", "app"
      type "pubid:itu:supplement", "sup"
      type "pubid:itu:amendment", "amd"
      type "pubid:itu:corrigendum", "cor"
      type "pubid:itu:addendum", "add"
      type "pubid:itu:errata", "err"
    end
  end
end
