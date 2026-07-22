# frozen_string_literal: true

module Pubid
  module Ietf
    module Identifiers
      # An FYI (For Your Information) sub-series id, e.g. "FYI 1".
      class Fyi < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :fyi,
            stage_code: :published,
            type_code: :fyi,
            abbr: ["FYI"],
            name: "For Your Information",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :fyi, web: :fyi, title: "For Your Information", short: "FYI" }
        end
      end
    end
  end
end
