# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Test Report Form identifier class
      # Single Responsibility: Represents IEC TRF documents
      # Can embed CISPR identifiers for IECEE TRF format
      class TestReportForm < Base
        # TRF can embed a CISPR identifier (MODEL-DRIVEN)
        attribute :cispr_identifier, Identifier, polymorphic: true, default: -> {
        }

        # TRF has type abbreviation for parsing
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :trf,
            stage_code: :published,
            type_code: :trf,
            abbr: ["TRF"],
            name: "Test Report Form",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :trf,
            web: :test_report_form, title: "Test Report Form", short: "TRF" }
        end

        # Override publisher_portion to add TRF with space
        def publisher_portion
          result = publisher.to_s

          if typed_stage && typed_stage.abbreviation == "TRF"
            result += " TRF"
          end

          result
        end

        # TRF uses special rendering via the Renderer
      end
    end
  end
end
