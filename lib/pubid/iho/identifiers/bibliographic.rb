# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      # IHO Bibliographic Publication (B series).
      # Example: IHO B-4 2.19.0.
      class Bibliographic < Identifier
        def self.type
          { key: :bibliographic, title: "Bibliographic Publication",
            short: "B" }
        end
      end
    end
  end
end
