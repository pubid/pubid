require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
  module Identifiers
    class TechnicalSpecification < SingleIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }
      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :pwits,
          stage_code: :pwi,
          type_code: :ts,
          abbr: ["PWI TS"],
          name: "Proposed Work Item for Technical Specification",
          harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
        ),
        Components::TypedStage.new(
          code: :npts,
          stage_code: :np,
          type_code: :ts,
          abbr: ["NP TS"],
          name: "New Work Item Proposal for Technical Specification",
          harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
        ),

        Components::TypedStage.new(
          code: :awits,
          stage_code: :awi,
          type_code: :ts,
          abbr: ["AWI TS"],
          name: "Approved Work Item for Technical Specification",
          harmonized_stages: %w[10.99 20.00],
        ),

        Components::TypedStage.new(
          code: :wdts,
          stage_code: :wd,
          type_code: :ts,
          abbr: ["WD TS"],
          name: "Working Draft Technical Specification",
          harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
        ),

        Components::TypedStage.new(
          code: :cdts,
          stage_code: :cd,
          type_code: :ts,
          abbr: ["CD TS"],
          name: "Committee Draft Technical Specification",
          harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
        ),
        Components::TypedStage.new(
          code: :pdts,
          stage_code: :cd,
          type_code: :ts,
          abbr: ["PDTS"],
          name: "Proposed Draft Technical Specification",
          harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
        ),

        Components::TypedStage.new(
          code: :dts,
          stage_code: :dts,
          type_code: :ts,
          abbr: ["DTS"],
          name: "Draft Technical Specification",
          harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
        ),
        Components::TypedStage.new(
          code: :fdts,
          stage_code: :fdts,
          type_code: :ts,
          abbr: ["FDTS"],
          name: "Final Draft Technical Specification",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),

        Components::TypedStage.new(
          code: :prfts,
          stage_code: :prf,
          type_code: :ts,
          abbr: ["PRF TS"],
          name: "Proof Technical Specification",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :pubts,
          stage_code: :published,
          type_code: :ts,
          abbr: ["TS"],
          name: "Published Technical Specification",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :ts, title: "Technical Specification", short: "TS" }
      end

    end
  end
end
end