# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Technology Report identifier class
      # Single Responsibility: Represents IEC Technology Report documents
      class TechnologyReport < Base
        # Technology Reports have full phrase as type abbreviation
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :tec,
            stage_code: :published,
            type_code: :tec,
            abbr: ["Technology Report"],
            name: "Technology Report",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :tec, title: "Technology Report", short: "Technology Report" }
        end

      end
    end
  end
end
