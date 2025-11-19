require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Iec
    module Identifiers
      # Guide identifier class
      # Single Responsibility: Represents IEC Guide documents
      class Guide < Base
        # Convert v1 hash-based TYPED_STAGES to v2 object-based
        # From gems/pubid-iec/lib/pubid/iec/identifier/guide.rb
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :dguide,
            stage_code: :draft,
            type_code: :guide,
            abbr: ["DGuide"],
            name: "Draft Guide",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.98 40.99]
          ),
          PubidNew::Components::TypedStage.new(
            code: :fdguide,
            stage_code: :final_draft,
            type_code: :guide,
            abbr: ["FDGuide"],
            name: "Final Draft Guide",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99]
          ),
          PubidNew::Components::TypedStage.new(
            code: :guide,
            stage_code: :published,
            type_code: :guide,
            abbr: ["GUIDE", "Guide"],
            name: "Guide",
            harmonized_stages: %w[60.00 60.60]
          )
        ].freeze

        def self.type
          { key: :guide, title: "Guide", short: %w[Guide GUIDE] }
        end

        # Override publisher_portion to handle Guide formatting
        # If copublishers exist, use parent implementation
        def publisher_portion
          # If copublishers, delegate to parent (SingleIdentifier) which handles them
          return super if copublishers&.any?

          # No copublishers: simple Guide formatting
          result = publisher.to_s

          if typed_stage
            abbr = typed_stage.abbreviation
            result += " #{abbr}" unless abbr.empty?
          end

          result
        end
      end
    end
  end
end