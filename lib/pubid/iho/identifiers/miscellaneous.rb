# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      # IHO Miscellaneous Publication (M series).
      # Example: IHO M-3 2.0.0.
      class Miscellaneous < Base
        def self.type
          { key: :miscellaneous, title: "Miscellaneous Publication",
            short: "M" }
        end
      end
    end
  end
end
