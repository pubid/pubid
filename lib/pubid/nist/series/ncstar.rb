# frozen_string_literal: true

module Pubid
  module Nist
    module Series
      # NCSTAR series: letter suffix in letter_number stays in the number
      # (e.g., "NIST NCSTAR 1-1A" — "1A" remains the compound suffix).
      # Unlike MONO, first_number letter suffix is NOT preserved.
      class Ncstar < Base
        def self.cast_letter_number(value, _parsed_hash)
          full = combine_letter_suffix(value)
          return nil if full.nil? || full.empty?

          value[:letter_suffix] = full
          value
        end
      end
    end
  end
end
