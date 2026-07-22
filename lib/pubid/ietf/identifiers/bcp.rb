# frozen_string_literal: true

module Pubid
  module Ietf
    module Identifiers
      # A BCP (Best Current Practice) sub-series id, e.g. "BCP 3".
      class Bcp < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :bcp,
            stage_code: :published,
            type_code: :bcp,
            abbr: ["BCP"],
            name: "Best Current Practice",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :bcp, web: :bcp, title: "Best Current Practice", short: "BCP" }
        end
      end
    end
  end
end
