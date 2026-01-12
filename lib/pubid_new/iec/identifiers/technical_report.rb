require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Iec
    module Identifiers
      # Technical Report identifier class
      # Single Responsibility: Represents IEC Technical Report documents
      class TechnicalReport < Base
        # Convert v1 hash-based TYPED_STAGES to v2 object-based
        # From gems/pubid-iec/lib/pubid/iec/identifier/technical_report.rb
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :dtr,
            stage_code: :draft,
            type_code: :tr,
            abbr: ["DTR"],
            name: "Draft Technical Report",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          PubidNew::Components::TypedStage.new(
            code: :tr,
            stage_code: :published,
            type_code: :tr,
            abbr: ["TR"],
            name: "Technical Report",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        # Project stages specific to Technical Reports
        # These are IEC-specific workflow stages
        PROJECT_STAGES = {
          adtr: {
            abbr: "ADTR",
            name: "Approved for DTR",
            harmonized_stages: %w[40.99],
          },
          cdtr: {
            abbr: "CDTR",
            name: "Draft circulated as DTR",
            harmonized_stages: %w[50.20],
          },
          dtrm: {
            abbr: "DTRM",
            name: "Rejected DTR to be discussed at meeting",
            harmonized_stages: %w[50.92],
          },
          ndtr: {
            abbr: "NDTR",
            name: "DTR rejected",
            harmonized_stages: %w[50.92],
          },
          prvdtr: {
            abbr: "PRVDTR",
            name: "Preparation of RVDTR",
            harmonized_stages: %w[50.60],
          },
          tdtr: {
            abbr: "TDTR",
            name: "Translation of DTR",
            harmonized_stages: %w[50.00],
          },
        }.freeze

        def self.type
          { key: :tr, title: "Technical Report", short: "TR" }
        end

        # Override publisher_portion to handle TR formatting
        # If copublishers exist, use parent implementation
        def publisher_portion
          # If copublishers, delegate to parent (SingleIdentifier) which handles them
          return super if copublishers&.any?

          # No copublishers: simple TR formatting
          result = publisher.to_s

          if typed_stage
            abbr = typed_stage.abbreviation
            # For TR: always use space (IEC convention for ALL publishers)
            result += " #{abbr}" unless abbr.empty?
          end

          result
        end
      end
    end
  end
end
