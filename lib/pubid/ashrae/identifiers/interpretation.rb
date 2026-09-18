# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Ashrae
    module Identifiers
      # Interpretation identifier for ASHRAE standards
      # Represents a collection of interpretations for a base standard
      # Examples:
      # - Interpretations for Standard 15.2-2022
      # - Interpretations for Standard 52.1-1992
      class Interpretation < SupplementIdentifier
        # Mirrors its four sibling supplement types: without it
        # Renderers::MrString slugs the interpretation FLAT off attributes it
        # does not have, instead of recursing into `base`. An interpretation
        # carries no field of its own, so the marker alone is the suffix.
        def mr_supplement_suffix
          "interp"
        end

        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["Interpretations"],
            type_code: "interpretation",
            stage_code: "published",
          ),
        ].freeze

        def self.type
          { key: :interpretation, title: "ASHRAE Interpretations",
            short: "Interpretations" }
        end
      end
    end
  end
end
