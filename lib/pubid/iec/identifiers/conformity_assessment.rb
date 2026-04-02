require_relative "base"
require_relative "../../components/typed_stage"

module Pubid
  module Iec
    module Identifiers
      # Conformity Assessment identifier class
      # Single Responsibility: Represents IEC CA documents
      class ConformityAssessment < Base
        # Conformity Assessment has CA as type abbreviation
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :ca,
            stage_code: :published,
            type_code: :ca,
            abbr: ["CA"],
            name: "Conformity Assessment",
            harmonized_stages: %w[60.00 60.60]
          )
        ].freeze

        def self.type
          { key: :ca, title: "Conformity Assessment", short: "CA" }
        end

        # Override publisher_portion to add /CA
        def publisher_portion
          result = publisher.to_s

          if typed_stage && typed_stage.abbreviation == "CA"
            result += " CA"
          end

          result
        end
      end
    end
  end
end