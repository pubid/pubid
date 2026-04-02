# frozen_string_literal: true

require_relative "supplement_identifier"

module PubidNew
  module Ieee
    module Identifiers
      # Interpretation identifier for IEEE standards
      # Represents an interpretation sheet or clarification
      # Example: IEEE Std 1076/INT-1991, IEEE Std 1003.1-1988/INT
      class InterpretationIdentifier < SupplementIdentifier
        attribute :int_year, :string

        # TYPED_STAGES for interpretation
        # Interpretation uses "INT" abbreviation
        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["INT"],
            type_code: "interpretation",
            stage_code: "published",
          ),
        ].freeze

        def to_s
          return base_identifier.to_s unless base_identifier

          # Format: BASE/INT or BASE/INT-YEAR
          result = base_identifier.to_s
          result += "/INT"
          result += "-#{int_year}" if int_year
          result
        end
      end
    end
  end
end
