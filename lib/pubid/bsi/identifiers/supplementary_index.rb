# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # SupplementaryIndex represents BSI supplementary index documents
      # Format: BS {number} Supplementary Index:{year}
      #
      # Examples:
      #   BS 185 Supplementary Index:1965
      class SupplementaryIndex < SingleIdentifier
        # TYPED_STAGES for supplementary index (published by default)
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubsupplementaryindex,
            stage_code: :published,
            type_code: :supplementary_index,
            abbr: ["BS"],
            name: "Supplementary Index",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          {
            key: :supplementary_index,
            title: "Supplementary Index",
            short: "BS",
          }
        end

      end
    end
  end
end
