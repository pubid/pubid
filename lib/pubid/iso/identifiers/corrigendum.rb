# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      class Corrigendum < SupplementIdentifier

        TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :pwi_cor,
            abbr: ["PWI Cor"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :cor,
            stage_code: :proposal,
            name: "Proposed Work Item for Corrigendum",
            harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :npcor,
            abbr: ["NP Cor"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :cor,
            stage_code: :proposal,
            name: "New Work Item Proposal for Corrigendum",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :awicor,
            abbr: ["AWI Cor"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :cor,
            stage_code: :preliminary,
            name: "Approved Work Item for Corrigendum",
            harmonized_stages: %w[10.99 20.00],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :wdcor,
            abbr: ["WD Cor"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :cor,
            stage_code: :working_draft,
            name: "Working Draft for Corrigendum",
            harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :cdcor,
            abbr: ["CD Cor", "pDCOR"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :cor,
            stage_code: :cd,
            name: "Committee Draft for Corrigendum",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :dcor,
            abbr: ["DCor", "DCOR", "DIS Cor"],
            short_abbr: "DCOR",
            long_abbr: "DCor",
            type_code: :cor,
            stage_code: :dcor,
            name: "Draft Corrigendum",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :fdcor,
            abbr: ["FDCor", "FDCOR", "FCOR", "FDIS Cor"],
            short_abbr: "FDCOR",
            long_abbr: "FDCor",
            type_code: :cor,
            stage_code: :fdcor,
            name: "Final Draft Corrigendum",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :prfcor,
            abbr: ["PRF Cor"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :cor,
            stage_code: :prf,
            name: "Proof Corrigendum",
            harmonized_stages: %w[50.00],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :pubcor,
            abbr: ["Cor", "COR", "Cor."],
            short_abbr: "COR",
            long_abbr: "Cor",
            type_code: :cor,
            stage_code: :published,
            name: "Corrigendum",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :cor,
            web: :corrigendum, title: "Corrigendum", short: "COR" }
        end
      end
    end
  end
end
