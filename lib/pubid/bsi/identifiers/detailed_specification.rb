# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Detailed Specification identifier with N or C notation
      # Examples: "BS 9074 N002:1974", "BS 9300 C155-168:1971"
      class DetailedSpecification < SingleIdentifier
        attribute :spec_code, Components::Code

        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :detailed_spec,
            stage_code: :published,
            type_code: :detailed_specification,
            abbr: ["DETAILED SPEC"],
            name: "Detailed Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          {
            key: :detailed_specification,
            title: "Detailed Specification",
            short: "DETAILED SPEC",
          }
        end

      end
    end
  end
end
