# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      # IHO Bibliographic Publication (B series).
      # Example: IHO B-4 2.19.0.
      class Bibliographic < Base
        def self.type
          { key: :bibliographic, title: "Bibliographic Publication", short: "B" }
        end

        def type
          self.class.type
        end
      end
    end
  end
end
