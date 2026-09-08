# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Societal Technology Trend Report identifier class
      # Single Responsibility: Represents IEC STTR documents
      class SocietalTechnologyTrendReport < Base
        # Societal Technology Trend Reports have full phrase as type abbreviation
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :sttr,
            stage_code: :published,
            type_code: :sttr,
            abbr: ["Trend Report"],
            name: "Societal and Technology Trend Report",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :sttr,
            web: :societal_technology_trend_report, title: "Societal and Technology Trend Report",
            short: "Trend Report" }
        end

      end
    end
  end
end
