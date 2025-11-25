require_relative "../supplement_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
  module Identifiers
    class Corrigendum < SupplementIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :pwicor,
          stage_code: :pwi,
          type_code: :cor,
          abbr: ["PWI Cor"],
          name: "Proposed Work Item for Corrigendum",
          harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
        ),
        Components::TypedStage.new(
          code: :npcor,
          stage_code: :np,
          type_code: :cor,
          abbr: ["NP Cor"],
          name: "New Work Item Proposal for Corrigendum",
          harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
        ),
        Components::TypedStage.new(
          code: :awicor,
          stage_code: :awi,
          type_code: :cor,
          abbr: ["AWI Cor"],
          name: "Approved Work Item for Corrigendum",
          harmonized_stages: %w[10.99 20.00],
        ),
        Components::TypedStage.new(
          code: :wdcor,
          stage_code: :wd,
          type_code: :cor,
          abbr: ["WD Cor"],
          name: "Working Draft for Corrigendum",
          harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
        ),
        Components::TypedStage.new(
          code: :cdcor,
          stage_code: :cd,
          type_code: :cor,
          abbr: ["CD Cor", "pDCOR", "pDCOR."],
          name: "Committee Draft for Corrigendum",
          harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
        ),
        Components::TypedStage.new(
          code: :dcor,
          stage_code: :dcor,
          type_code: :cor,
          abbr: ["DCor", "DCOR"], # "DCOR" is legacy
          name: "Draft Corrigendum",
          harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
        ),
        Components::TypedStage.new(
          code: :fdcor,
          stage_code: :fdcor,
          type_code: :cor,
          abbr: ["FDCor", "FDCOR", "FCOR"], # "FDCOR", "FCOR" is legacy
          name: "Final Draft Corrigendum",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :prfcor,
          stage_code: :prf,
          type_code: :cor,
          abbr: ["PRF Cor"],
          name: "Proof Corrigendum",
          harmonized_stages: %w[60.00],
        ),
        Components::TypedStage.new(
          code: :pubcor,
          stage_code: :published,
          type_code: :cor,
          abbr: ["Cor", "COR", "Cor."],
          name: "Corrigendum",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :cor, title: "Corrigendum", short: "COR" }
      end

    end
  end
end
end