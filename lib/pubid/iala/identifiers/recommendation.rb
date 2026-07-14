# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA Recommendations (R series).
      # Examples: R0103 Ed 3.1, R0126 Ed 2.0, R1024 Ed 1.0.
      class Recommendation < Base
        number_width 4

        def self.type
          { key: :recommendation, title: "Recommendation", short: "R" }
        end
      end
    end
  end
end
