# frozen_string_literal: true

module Pubid
  module W3c
    module Identifiers
      # W3C Proposed Recommendation. Printed token: "PR".
      # Example: "W3C PR-InkML-20110510".
      class ProposedRecommendation < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pr,
            stage_code: :proposed_recommendation,
            type_code: :pr,
            abbr: ["PR"],
            name: "Proposed Recommendation",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :pr, web: :proposed_recommendation,
            title: "Proposed Recommendation", short: "PR" }
        end

        def type_prefix
          "PR"
        end
      end
    end
  end
end
