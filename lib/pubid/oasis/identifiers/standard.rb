# frozen_string_literal: true

module Pubid
  module Oasis
    module Identifiers
      # The sole OASIS identifier type. OASIS records carry no document-type
      # distinction in the printed id (every record is `type: OASIS`); the
      # approval stage lives in the `stage` component field, not in the class.
      # Example: "OASIS OSLC-CoreShapes-3.0-PS01-Pt8".
      class Standard < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :oasis,
            stage_code: :published,
            type_code: :oasis,
            abbr: ["OASIS"],
            name: "OASIS Standard",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :oasis, web: :standard, title: "OASIS Standard",
            short: "OASIS" }
        end
      end
    end
  end
end
