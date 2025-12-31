# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NIST NCSTAR (National Construction Safety Team Act Reports)
      # Examples:
      # - "NIST NCSTAR 1-1Cv1" → "NIST NCSTAR 1-1C, Volume 1"
      # - "NIST NCSTAR 1-1b" → "NIST NCSTAR 1-1B"
      # - "NIST NCSTAR 1-1cv1" → "NIST NCSTAR 1-1Cv1"
      class Ncstar < Base
        def series_code
          "NCSTAR"
        end
      end
    end
  end
end