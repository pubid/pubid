# frozen_string_literal: true

module Pubid
  module W3c
    module Identifiers
      # W3C Recommendation (a published standard). Printed token: "REC".
      # Example: "W3C REC-ATAG10-20000203".
      class Recommendation < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :rec,
            stage_code: :recommendation,
            type_code: :rec,
            abbr: ["REC"],
            name: "Recommendation",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :rec, web: :recommendation, title: "Recommendation",
            short: "REC" }
        end

        def type_prefix
          "REC"
        end
      end
    end
  end
end
