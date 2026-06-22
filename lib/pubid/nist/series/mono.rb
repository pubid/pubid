# frozen_string_literal: true

module Pubid
  module Nist
    module Series
      # MONO series: letter suffix preserved in first_number AND in
      # letter_number (e.g., "NBS MONO 1A" — letter stays in the number).
      class Mono < LetterPreserving
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
