# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA Guidelines (G series).
      # Examples: G1015 Ed 2.2, G1078 Ed 2.1.
      class Guideline < Identifier
        number_width 4

        def self.type
          { key: :guideline, title: "Guideline", short: "G" }
        end
      end
    end
  end
end
