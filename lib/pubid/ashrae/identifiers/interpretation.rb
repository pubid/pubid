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
