# frozen_string_literal: true

module Pubid
  module W3c
    module Identifiers
      # W3C Candidate Recommendation Draft. Printed token: "CRD".
      # Example: "W3C CRD-accelerometer-20250212".
      class CandidateRecommendationDraft < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :crd,
            stage_code: :candidate_recommendation_draft,
            type_code: :crd,
            abbr: ["CRD"],
            name: "Candidate Recommendation Draft",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :crd, web: :candidate_recommendation_draft,
            title: "Candidate Recommendation Draft", short: "CRD" }
        end

        def type_prefix
          "CRD"
        end
      end
    end
  end
end
