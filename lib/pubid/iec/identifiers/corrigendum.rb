require_relative "../supplement_identifier"
# frozen_string_literal: true
require_relative "../../components/typed_stage"

module Pubid
  module Iec
    module Identifiers
      # Corrigendum Identifier
      class Corrigendum < SupplementIdentifier
        attribute :type, Pubid::Components::Type, default: -> { self.class.type[:key] }

        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :cdcor,
            stage_code: :cd,
            type_code: :cor,
            abbr: ["CDCor"],
            short_abbr: "CDCor",
            long_abbr: "CD Cor",
            name: "Committee Draft Corrigendum",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.98 30.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :dcor,
            stage_code: :dcor,
            type_code: :cor,
            abbr: ["DCOR"],
            short_abbr: "DCOR",
            long_abbr: "DCor",
            name: "Draft Corrigendum",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.98 40.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :fdcor,
            stage_code: :fdcor,
            type_code: :cor,
            abbr: ["FDCOR"],
            short_abbr: "FDCOR",
            long_abbr: "FDCor",
            name: "Final Draft Corrigendum",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :pubcor,
            stage_code: :published,
            type_code: :cor,
            abbr: ["Cor", "COR"],
            short_abbr: "COR",
            long_abbr: "Cor",
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
