# frozen_string_literal: true

module Pubid
  module Nist
    # Per-series behavior policies for the NIST caster and builder.
    #
    # Series-specific casting decisions (letter-suffix preservation, IR revision
    # handling, FIPS date format, etc.) live behind this interface so the
    # caster and builder never read `parsed_hash[:series]` directly. A series
    # bug now lives in exactly one file.
    module Series
      autoload :Base, "#{__dir__}/series/base"
      autoload :LetterPreserving, "#{__dir__}/series/letter_preserving"
      autoload :Crpl, "#{__dir__}/series/crpl"
      autoload :Fips, "#{__dir__}/series/fips"
      autoload :Ir, "#{__dir__}/series/ir"
      autoload :Mono, "#{__dir__}/series/mono"
      autoload :Ncstar, "#{__dir__}/series/ncstar"

      # Order matters: longer / more-specific codes first so that substrings
      # do not shadow them (e.g., LCIRC must be matched before IR, since
      # "LCIRC" contains "IR").
      REGISTRY = [
        ["LCIRC", LetterPreserving],
        ["FIPS",  Fips],
        ["CRPL",  Crpl],
        ["NCSTAR", Ncstar],
        ["MONO",  Mono],
        ["IR",    Ir],
        ["MP",    LetterPreserving],
        ["RPT",   LetterPreserving],
        ["LC",    LetterPreserving],
      ].freeze

      def self.for(parsed_hash)
        return Base if parsed_hash.nil?

        series_code = parsed_hash[:series]
        return Base if series_code.nil?

        series_str = series_code.to_s.upcase
        REGISTRY.each do |code, klass|
          return klass if series_str.include?(code)
        end
        Base
      end
    end
  end
end
