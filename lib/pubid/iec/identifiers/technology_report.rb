require_relative "base"
require_relative "../../components/typed_stage"

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

        # Override publisher_portion to add Technology Report
        def publisher_portion
          result = publisher.to_s

          if typed_stage && typed_stage.abbreviation == "Technology Report"
            result += " Technology Report"
          end

          result
        end
      end
    end
  end
end
