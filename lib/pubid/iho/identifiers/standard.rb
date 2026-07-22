# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      # IHO Standards and Specifications (S series).
      # Examples: IHO S-44 5.0.0, IHO S-100 Part 4a 1.0.0, IHO S-65 Ap. A 1.0.0.
      class Standard < Identifier
        def self.type
          { key: :standard, title: "Standards and Specifications", short: "S" }
        end
      end
    end
  end
end
