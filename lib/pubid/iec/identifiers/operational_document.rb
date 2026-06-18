# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Operational Document identifier class
      # Single Responsibility: Represents IEC OD documents
      class OperationalDocument < Base
        # Operational Documents have OD as type abbreviation
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :od,
            stage_code: :published,
            type_code: :od,
            abbr: ["OD"],
            name: "Operational Document",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :od,
            web: :operational_document, title: "Operational Document", short: "OD" }
        end

        # Override publisher_portion to add OD
        def publisher_portion
          result = publisher.to_s

          if typed_stage && typed_stage.abbreviation == "OD"
            result += " OD"
          end

          result
        end
      end
    end
  end
end
