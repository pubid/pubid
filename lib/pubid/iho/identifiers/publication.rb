# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      # IHO Publication (P series).
      # Examples: IHO P-1 1.0.0, IHO P-1/21 1.0.0, IHO P-6-3 1.0.0.
      class Publication < Base
        def self.type
          { key: :publication, title: "Publication", short: "P" }
        end

        def type
          self.class.type
        end
      end
    end
  end
end
