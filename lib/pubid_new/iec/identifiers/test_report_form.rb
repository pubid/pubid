require_relative "base"
# frozen_string_literal: true
require_relative "../../components/typed_stage"

module PubidNew
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
          PubidNew::Components::TypedStage.new(
            code: :trf,
            stage_code: :published,
            type_code: :trf,
            abbr: ["TRF"],
            name: "Test Report Form",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :trf, title: "Test Report Form", short: "TRF" }
        end

        # Override publisher_portion to add TRF with space
        def publisher_portion
          result = publisher.to_s

          if typed_stage && typed_stage.abbreviation == "TRF"
            result += " TRF"
          end

          result
        end

        # TRF uses special rendering
        def to_s(_format = :short)
          parts = []

          # Publisher and type portion
          parts << publisher_portion

          # If CISPR identifier embedded, render it with TRF date
          if cispr_identifier
            cispr_parts = []
            cispr_parts << cispr_identifier.publisher.body

            # Build number portion with part
            num_str = cispr_identifier.number.to_s
            num_str += "-#{cispr_identifier.part}" if cispr_identifier.part && cispr_identifier.part.to_s != ""
            cispr_parts << num_str

            # Join with space and add TRF year
            cispr_str = cispr_parts.join(" ")
            cispr_str += ":#{date.year}" if date

            parts << " #{cispr_str}"
          else
            # Normal TRF: number portion
            parts << number_portion
          end

          # TRF info if present (handles version, decision sheet, etc.)
          parts << trf_info.to_s if trf_info && !trf_info.empty?

          parts.compact.join
        end
      end
    end
  end
end
