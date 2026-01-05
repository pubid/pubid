require_relative "../supplement_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
    module Identifiers
      class Corrigendum < SupplementIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pwi_cor,
            abbr: ["PWI Cor"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :cor,
            stage_code: :proposal,
          ),
          Components::TypedStage.new(
            code: :npcor,
            abbr: ["NP Cor"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :cor,
            stage_code: :proposal,
          ),
          Components::TypedStage.new(
            code: :awicor,
            abbr: ["AWI Cor"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :cor,
            stage_code: :preliminary,
          ),
          Components::TypedStage.new(
            code: :wdcor,
            abbr: ["WD Cor"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :cor,
            stage_code: :working_draft,
          ),
          Components::TypedStage.new(
            code: :cdcor,
            abbr: ["CD Cor", "pDCOR"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :cor,
            stage_code: :cd,
          ),
          Components::TypedStage.new(
            code: :dcor,
            abbr: ["DCor", "DCOR"],
            short_abbr: "DCOR",
            long_abbr: "DCor",
            type_code: :cor,
            stage_code: :dcor,
          ),
          Components::TypedStage.new(
            code: :fdcor,
            abbr: ["FDCor", "FDCOR", "FCOR"],
            short_abbr: "FDCOR",
            long_abbr: "FDCor",
            type_code: :cor,
            stage_code: :fdcor,
          ),
          Components::TypedStage.new(
            code: :prfcor,
            abbr: ["PRF Cor"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :cor,
            stage_code: :prf,
          ),
          Components::TypedStage.new(
            code: :pubcor,
            abbr: ["Cor", "COR", "Cor."],
            short_abbr: "COR",
            long_abbr: "Cor",
            type_code: :cor,
            stage_code: :published,
          ),
        ].freeze

        def self.type
          { key: :cor, title: "Corrigendum", short: "COR" }
        end

      end
    end
  end
end
