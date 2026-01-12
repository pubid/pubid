require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Iec
    module Identifiers
      # Publicly Available Specification identifier class
      # Single Responsibility: Represents IEC PAS documents
      class PubliclyAvailableSpecification < Base
        # Convert v1 hash-based TYPED_STAGES to v2 object-based
        # From gems/pubid-iec/lib/pubid/iec/identifier/publicly_available_specification.rb
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :dpas,
            stage_code: :draft,
            type_code: :pas,
            abbr: ["DPAS"],
            name: "Draft Publicly Available Specification",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          PubidNew::Components::TypedStage.new(
            code: :cdpas,
            stage_code: :circulated,
            type_code: :pas,
            abbr: ["CDPAS"],
            name: "Draft circulated as DPAS",
            harmonized_stages: %w[50.20],
          ),
          PubidNew::Components::TypedStage.new(
            code: :pas,
            stage_code: :published,
            type_code: :pas,
            abbr: ["PAS"],
            name: "Publicly Available Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        # Project stages specific to PAS
        PROJECT_STAGES = {
          PRVDPAS: {
            abbr: "PRVDPAS",
            name: "Preparation of RVDPAS",
            harmonized_stages: %w[50.60],
          },
        }.freeze

        def self.type
          { key: :pas, title: "Publicly Available Specification", short: "PAS" }
        end

        # Override publisher_portion to add PAS or DPAS stage
        def publisher_portion
          result = publisher.to_s

          if typed_stage
            abbr = typed_stage.abbreviation
            # PAS uses space for all stages
            result += " #{abbr}" unless abbr.empty?
          end

          result
        end
      end
    end
  end
end
