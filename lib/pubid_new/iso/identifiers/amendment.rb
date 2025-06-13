require_relative "../supplement_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
  module Identifiers
    class Amendment < SupplementIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :pwiamd,
          stage_code: :pwi,
          type_code: :amd,
          abbr: ["PWI Amd"],
          name: "Proposed Work Item for Amendment",
          harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
        ),
        Components::TypedStage.new(
          code: :npamd,
          stage_code: :np,
          type_code: :amd,
          abbr: ["NP Amd"],
          name: "New Work Item Proposal for Amendment",
          harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
        ),
        Components::TypedStage.new(
          code: :awiamd,
          stage_code: :awi,
          type_code: :amd,
          abbr: ["AWI Amd"],
          name: "Approved Work Item for Amendment",
          harmonized_stages: %w[10.99 20.00],
        ),
        Components::TypedStage.new(
          code: :wdamd,
          stage_code: :wd,
          type_code: :amd,
          abbr: ["WD Amd"],
          name: "Working Draft for Amendment",
          harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
        ),
        Components::TypedStage.new(
          code: :cdamd,
          stage_code: :cd,
          type_code: :amd,
          abbr: ["CD Amd", "PDAM"],
          name: "Committee Draft for Amendment",
          harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
        ),
        Components::TypedStage.new(
          code: :damd,
          stage_code: :damd,
          type_code: :amd,
          abbr: ["DAM", "DAmd", "FPDAM"], # "DAmd", "FPDAM" is legacy
          name: "Draft Amendment",
          harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
        ),
        Components::TypedStage.new(
          code: :fdamd,
          stage_code: :fdamd,
          type_code: :amd,
          abbr: ["FDAM", "FDAmd"], # "FDAmd" is legacy
          name: "Final Draft Amendment",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :prfamd,
          stage_code: :prf,
          type_code: :amd,
          abbr: ["PRF Amd"],
          name: "Proof Amendment",
          harmonized_stages: %w[60.00],
        ),
        Components::TypedStage.new(
          code: :pubamd,
          stage_code: :published,
          type_code: :amd,
          abbr: ["Amd", "AMD", "Amd."],
          name: "Amendment",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :amd, title: "Amendment", short: "AMD" }
      end
    end
  end
end
end