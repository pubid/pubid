# frozen_string_literal: true

module Pubid
  module Nist
    module Series
      # Series where the letter suffix on `first_number` stays in the number.
      # Used for: RPT, MP, LC, CRPL, MONO, FIPS, IR (subclasses refine further).
      class LetterPreserving < Base
        def self.preserve_letter_suffix?(_parsed_hash)
          true
        end
      end
    end
  end
end
