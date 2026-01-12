require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Iec
    module Identifiers
      # Technical Specification identifier class
      # Single Responsibility: Represents IEC Technical Specification documents
      class TechnicalSpecification < Base
        # Convert v1 hash-based TYPED_STAGES to v2 object-based
        # From gems/pubid-iec/lib/pubid/iec/identifier/technical_specification.rb
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :dts,
            stage_code: :draft,
            type_code: :ts,
            abbr: ["DTS"],
            name: "Draft Technical Specification",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          PubidNew::Components::TypedStage.new(
            code: :ts,
            stage_code: :published,
            type_code: :ts,
            abbr: ["TS"],
            name: "Technical Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        # Project stages specific to Technical Specifications
        # These are IEC-specific workflow stages
        PROJECT_STAGES = {
          adts: {
            abbr: "ADTS",
            name: "Approved for DTS",
            harmonized_stages: %w[40.99],
          },
          cdts: {
            abbr: "CDTS",
            name: "Draft circulated as DTS",
            harmonized_stages: %w[50.20],
          },
          dtsm: {
            abbr: "DTSM",
            name: "Rejected DTS to be discussed at meeting",
            harmonized_stages: %w[50.92],
          },
          ndts: {
            abbr: "NDTS",
            name: "DTS rejected",
            harmonized_stages: %w[50.92],
          },
          prvdts: {
            abbr: "PRVDTS",
            name: "Preparation of RVDTS",
            harmonized_stages: %w[50.60],
          },
          tdts: {
            abbr: "TDTS",
            name: "Translation of DTS",
            harmonized_stages: %w[50.00],
          },
        }.freeze

        def self.type
          { key: :ts, title: "Technical Specification", short: "TS" }
        end

        # Override publisher_portion to handle TS formatting
        # If copublishers exist, use parent implementation
        def publisher_portion
          # If copublishers, delegate to parent (SingleIdentifier) which handles them
          return super if copublishers&.any?

          # No copublishers: simple TS formatting
          result = publisher.to_s

          if typed_stage
            abbr = typed_stage.abbreviation
            # TS uses space for all stages
            result += " #{abbr}" unless abbr.empty?
          end

          result
        end
      end
    end
  end
end
