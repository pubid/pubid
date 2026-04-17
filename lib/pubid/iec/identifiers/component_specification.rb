require_relative "base"
require_relative "../../components/typed_stage"

module Pubid
  module Iec
    module Identifiers
      # Component Specification identifier class
      # Single Responsibility: Represents IEC CS documents
      class ComponentSpecification < Base
        # Component Specifications have CS as type abbreviation
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :cs,
            stage_code: :published,
            type_code: :cs,
            abbr: ["CS"],
            name: "Component Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :cs, title: "Component Specification", short: "CS" }
        end

        # Override publisher_portion to add CS
        def publisher_portion
          result = publisher.to_s

          if typed_stage && typed_stage.abbreviation == "CS"
            result += " CS"
          end

          result
        end
      end
    end
  end
end
