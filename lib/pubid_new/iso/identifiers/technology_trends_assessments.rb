require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
  module Identifiers
    class TechnologyTrendsAssessments < SingleIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :pwitta,
          stage_code: :pwi,
          type_code: :tta,
          abbr: ["PWI TTA"],
          name: "Proposed Work Item for Technology Trends Assessments",
          harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
        ),

        Components::TypedStage.new(
          code: :nptta,
          stage_code: :np,
          type_code: :tta,
          abbr: ["NP TTA"],
          name: "New Work Item Proposal for Technology Trends Assessments",
          harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
        ),

        Components::TypedStage.new(
          code: :awitta,
          stage_code: :awi,
          type_code: :tta,
          abbr: ["AWI TTA"],
          name: "Approved Work Item for Technology Trends Assessments",
          harmonized_stages: %w[10.99 20.00],
        ),

        Components::TypedStage.new(
          code: :wdtta,
          stage_code: :wd,
          type_code: :tta,
          abbr: ["WD TTA"],
          name: "Working Draft for Technology Trends Assessments",
          harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
        ),

        Components::TypedStage.new(
          code: :cdtta,
          stage_code: :cd,
          type_code: :tta,
          abbr: ["CD TTA"],
          name: "Committee Draft for Technology Trends Assessments",
          harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
        ),

        Components::TypedStage.new(
          code: :dtta,
          stage_code: :draft,
          type_code: :tta,
          abbr: ["DTTA"],
          name: "Draft Technology Trends Assessments",
          harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
        ),
        Components::TypedStage.new(
          code: :fdtta,
          stage_code: :final_draft,
          type_code: :tta,
          abbr: ["FDTTA"],
          name: "Final Draft Technology Trends Assessments",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :prftta,
          stage_code: :prf,
          type_code: :tta,
          abbr: ["PRF TTA"],
          name: "Proof Technology Trends Assessments",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :pubtta,
          stage_code: :published,
          type_code: :tta,
          abbr: ["TTA"],
          name: "Published Technology Trends Assessments",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :tta, title: "Technology Trends Assessments", short: "TTA" }
      end

    end
  end
end
end