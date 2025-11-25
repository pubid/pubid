require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
  module Identifiers
    # Publicly Available Specification", Identifier
    class Pas < SingleIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :pwipas,
          stage_code: :pwi,
          type_code: :pas,
          abbr: ["PWI PAS"],
          name: "Proposed Work Item for Publicly Available Specification",
          harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
        ),
        Components::TypedStage.new(
          code: :nppas,
          stage_code: :np,
          type_code: :pas,
          abbr: ["NP PAS"],
          name: "New Work Item Proposal for Publicly Available Specification",
          harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
        ),
        Components::TypedStage.new(
          code: :awipas,
          stage_code: :awi,
          type_code: :pas,
          abbr: ["AWI PAS"],
          name: "Approved Work Item for Publicly Available Specification",
          harmonized_stages: %w[10.99 20.00],
        ),
        Components::TypedStage.new(
          code: :wdpas,
          stage_code: :wd,
          type_code: :pas,
          abbr: ["WD PAS"],
          name: "Working Draft for Publicly Available Specification",
          harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
        ),
        Components::TypedStage.new(
          code: :cdpas,
          stage_code: :cd,
          type_code: :pas,
          abbr: ["CD PAS"],
          name: "Committee Draft for Publicly Available Specification",
          harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
        ),
        Components::TypedStage.new(
          code: :dpas,
          stage_code: :dpas,
          type_code: :pas,
          abbr: ["DPAS"],
          name: "Draft Publicly Available Specification",
          harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
        ),

        Components::TypedStage.new(
          code: :fdpas,
          stage_code: :final_draft,
          type_code: :pas,
          abbr: ["FDPAS"],
          name: "Final Draft Publicly Available Specification",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),

        Components::TypedStage.new(
          code: :prfpas,
          stage_code: :prf,
          type_code: :pas,
          abbr: ["PRF PAS"],
          name: "Proof Publicly Available Specification",
          harmonized_stages: %w[60.00],
        ),
        Components::TypedStage.new(
          code: :pas,
          stage_code: :published,
          type_code: :pas,
          abbr: ["PAS"],
          name: "Publicly Available Specification",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :pas, title: "Publicly Available Specification", short: "PAS" }
      end
    end
  end
end
end