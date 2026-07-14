# frozen_string_literal: true

module Pubid
  module W3c
    module Identifiers
      # Obsolete W3C Recommendation. Printed token: "OBSL".
      # Example: "W3C OBSL-widgets-apis-20181011".
      class ObsoleteRecommendation < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :obsl,
            stage_code: :obsolete_recommendation,
            type_code: :obsl,
            abbr: ["OBSL"],
            name: "Obsolete Recommendation",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :obsl, web: :obsolete_recommendation,
            title: "Obsolete Recommendation", short: "OBSL" }
        end

        def type_prefix
          "OBSL"
        end
      end
    end
  end
end
