# frozen_string_literal: true

require "lutaml/model"
require_relative "../supplement_identifier"
require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
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

        def to_s
          return base_identifier.to_s unless base_identifier

          # Format: Interpretations for Standard 15.2-2022
          base_type = base_identifier.type || "Standard"
          result = "Interpretations for #{base_type} #{base_identifier.code}"
          result += "-#{base_identifier.year}" if base_identifier.year
          result
        end
      end
    end
  end
end
