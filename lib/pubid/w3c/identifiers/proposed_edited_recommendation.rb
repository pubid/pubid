# frozen_string_literal: true

module Pubid
  module W3c
    module Identifiers
      # W3C Proposed Edited Recommendation. Printed token: "PER".
      # Example: "W3C PER-rif-dtb-20121211".
      class ProposedEditedRecommendation < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :per,
            stage_code: :proposed_edited_recommendation,
            type_code: :per,
            abbr: ["PER"],
            name: "Proposed Edited Recommendation",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :per, web: :proposed_edited_recommendation,
            title: "Proposed Edited Recommendation", short: "PER" }
        end

        def type_prefix
          "PER"
        end
      end
    end
  end
end
