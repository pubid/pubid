# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      # IHO Publication (P series).
      # Examples: IHO P-1 1.0.0, IHO P-1/21 1.0.0, IHO P-6-3 1.0.0.
      # Series with no edition: IHO P-5 2024 (year),
      # IHO P-1 Vol. 30 No. 1 (volume and issue).
      class Publication < Identifier
        def self.type
          { key: :publication, title: "Publication", short: "P" }
        end
      end
    end
  end
end
