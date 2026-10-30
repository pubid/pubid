# frozen_string_literal: true

module Pubid
  module Gost
    # Grammar for GOST identifiers.
    #
    # Accepts the Latin and Cyrillic surface forms observed in the wild:
    #
    #   ГОСТ 14946-82                       (interstate, dated)
    #   ГОСТ 2.312                          (interstate, undated)
    #   ГОСТ Р 71039— 2023                  (national, em-dash + space)
    #   ГОСТ ISO 9692-1                     (copublisher, undated)
    #   ГОСТ Р МЭК 60794-1-23-2017          (Cyrillic copublisher)
    #   ГОСТ Р ИСО/МЭК МФС 10609-9-95      (compound copublisher + subtype)
    #   ГОСТ ISO Guide 30-2019              (copublisher + subtype "Guide")
    #   ГОСТ Р 58904-2020/ISO/TR 25901-1:2016  (IDT adoption, slash form)
    #
    # The parser captures three atoms:
    #   * :scope_r     — "R"/"Р" if Russian national, nil if interstate
    #   * :prefix_text — everything between scope_r and the number
    #                     (copublisher, subtype, or both) as a raw string
    #   * :raw         — digit runs separated by dots/dashes (number+year)
    #   * :adopted_raw — the foreign identifier after "/" (IDT adoption)
    #
    # The builder interprets prefix_text (splits copublisher vs subtype,
    # normalizes Cyrillic to Latin) and raw (splits number vs year).
    class Parser
      # Pre-parse ingestion normalizations (R2): every parse path feeds
      # the grammar the same normalized string.
      def self.normalize_input(string)
        string.strip
      end
    end
  end
end
