# frozen_string_literal: true

module Pubid
  module Nist
    module Series
      # FIPS series: letter suffix preserved; edition dates use modern format.
      class Fips < LetterPreserving
        def self.modern_edition_date?
          true
        end
      end
    end
  end
end
