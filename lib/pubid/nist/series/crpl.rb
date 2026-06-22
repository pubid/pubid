# frozen_string_literal: true

module Pubid
  module Nist
    module Series
      # CRPL series: letter suffix preserved in first_number.
      # Range parsing ("2_3-1") is handled by the dedicated :crpl_range case
      # in the caster; this class only carries the letter-suffix policy.
      class Crpl < LetterPreserving
      end
    end
  end
end
