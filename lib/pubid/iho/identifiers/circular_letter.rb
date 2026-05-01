# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      # IHO Circular Letter (C series).
      # Example: IHO C-13 1.0.0.
      class CircularLetter < Base
        def self.type
          { key: :circular_letter, title: "Circular Letter", short: "C" }
        end

        def type
          self.class.type
        end
      end
    end
  end
end
