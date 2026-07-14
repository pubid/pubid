# frozen_string_literal: true

module Pubid
  module W3c
    module Identifiers
      # W3C Candidate Recommendation. Printed token: "CR".
      # Example: "W3C CR-exi-20091208".
      class CandidateRecommendation < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :cr,
            stage_code: :candidate_recommendation,
            type_code: :cr,
            abbr: ["CR"],
            name: "Candidate Recommendation",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :cr, web: :candidate_recommendation,
            title: "Candidate Recommendation", short: "CR" }
        end

        def type_prefix
          "CR"
        end
      end
    end
  end
end
