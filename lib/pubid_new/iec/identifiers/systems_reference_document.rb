require_relative "base"
# frozen_string_literal: true
require_relative "../../components/typed_stage"

module PubidNew
  module Iec
    module Identifiers
      # Systems Reference Document identifier class
      # Single Responsibility: Represents IEC SRD documents
      class SystemsReferenceDocument < Base
        # Systems Reference Documents have SRD as type abbreviation
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :srd,
            stage_code: :published,
            type_code: :srd,
            abbr: ["SRD"],
            name: "Systems Reference Document",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :srd, title: "Systems Reference Document", short: "SRD" }
        end

        # Override publisher_portion to add SRD
        def publisher_portion
          result = publisher.to_s

          if typed_stage && typed_stage.abbreviation == "SRD"
            result += " SRD"
          end

          result
        end
      end
    end
  end
end
