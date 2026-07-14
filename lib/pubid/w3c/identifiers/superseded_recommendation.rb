# frozen_string_literal: true

module Pubid
  module W3c
    module Identifiers
      # Superseded W3C Recommendation. Printed token: "SPSD".
      # Example: "W3C SPSD-2dcontext-20210128".
      class SupersededRecommendation < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :spsd,
            stage_code: :superseded_recommendation,
            type_code: :spsd,
            abbr: ["SPSD"],
            name: "Superseded Recommendation",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :spsd, web: :superseded_recommendation,
            title: "Superseded Recommendation", short: "SPSD" }
        end

        def type_prefix
          "SPSD"
        end
      end
    end
  end
end
