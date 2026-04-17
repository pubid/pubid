require_relative "base"
# frozen_string_literal: true
require_relative "../../components/typed_stage"

module Pubid
  module Iec
    module Identifiers
      # Guide identifier class
      # Single Responsibility: Represents IEC Guide documents
      class Guide < Base
        # Convert v1 hash-based TYPED_STAGES to v2 object-based
        # From gems/pubid-iec/lib/pubid/iec/identifier/guide.rb
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pwi_guide,
            stage_code: :pwi,
            type_code: :guide,
            abbr: ["PWI Guide"],
            name: "Preliminary Work Item Guide",
            harmonized_stages: %w[00.00 00.20 00.60 00.98 00.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :np_guide,
            stage_code: :np,
            type_code: :guide,
            abbr: ["NP Guide"],
            name: "New Proposal Guide",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.98],
          ),
          Pubid::Components::TypedStage.new(
            code: :anw_guide,
            stage_code: :anw,
            type_code: :guide,
            abbr: ["ANW Guide"],
            name: "Approved New Work Item Guide",
            harmonized_stages: %w[10.99 20.00],
          ),
          Pubid::Components::TypedStage.new(
            code: :wd_guide,
            stage_code: :wd,
            type_code: :guide,
            abbr: ["WD Guide"],
            name: "Working Draft Guide",
            harmonized_stages: %w[20.20 20.60 20.98 20.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :cd_guide,
            stage_code: :cd,
            type_code: :guide,
            abbr: ["CD Guide"],
            name: "Committee Draft Guide",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.98 30.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :dguide,
            stage_code: :draft,
            type_code: :guide,
            abbr: ["DGuide"],
            name: "Draft Guide",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.98 40.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :fdguide,
            stage_code: :final_draft,
            type_code: :guide,
            abbr: ["FDGuide", "PRF Guide"],
            name: "Final Draft Guide",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :guide,
            stage_code: :published,
            type_code: :guide,
            abbr: ["GUIDE", "Guide"],
            name: "Guide",
            harmonized_stages: %w[60.00 60.60 90.20 90.60 90.92 90.93 90.99 95.20 95.60 95.92 95.99],
          ),
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
