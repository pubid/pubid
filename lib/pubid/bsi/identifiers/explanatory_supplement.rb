# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # ExplanatorySupplement represents BSI explanatory supplement documents
      # Format: BS {number}-{part}:Explanatory Supplement:{year}
      #
      # Examples:
      #   BS 5655-1:Explanatory Supplement:1981
      class ExplanatorySupplement < SingleIdentifier
        # TYPED_STAGES for explanatory supplement (published by default)
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubexplanatorysupplement,
            stage_code: :published,
            type_code: :explanatory_supplement,
            abbr: ["BS"],
            name: "Explanatory Supplement",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          {
            key: :explanatory_supplement,
            title: "Explanatory Supplement",
            short: "BS",
          }
        end

      end
    end
  end
end
