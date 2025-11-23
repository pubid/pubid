require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
    module Identifiers
      class TechnicalReport < SingleIdentifier
        attribute :type, ::PubidNew::Components::Type, default: -> {
          type[:key]
        }

        TYPED_STAGES = [
          ::PubidNew::Components::TypedStage.new(
            code: :pwitr,
            stage_code: :pwi,
            type_code: :tr,
            abbr: ["PWI TR"],
            name: "Proposed Work Item for Technical Report",
            harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
          ),
          ::PubidNew::Components::TypedStage.new(
            code: :nptr,
            stage_code: :np,
            type_code: :tr,
            abbr: ["NP TR"],
            name: "New Work Item Proposal for Technical Report",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
          ),

          ::PubidNew::Components::TypedStage.new(
            code: :awitr,
            stage_code: :awi,
            type_code: :tr,
            abbr: ["AWI TR"],
            name: "Approved Work Item for Technical Report",
            harmonized_stages: %w[10.99 20.00],
          ),

          ::PubidNew::Components::TypedStage.new(
            code: :wdtr,
            stage_code: :wd,
            type_code: :tr,
            abbr: ["WD TR"],
            name: "Working Draft Technical Report",
            harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
          ),

          ::PubidNew::Components::TypedStage.new(
            code: :cdtr,
            stage_code: :cd,
            type_code: :tr,
            abbr: ["CD TR"],
            name: "Committee Draft Technical Report",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),

          ::PubidNew::Components::TypedStage.new(
            code: :pdtr,
            stage_code: :cd,
            type_code: :tr,
            abbr: ["PDTR"],
            name: "Proposed Draft Technical Report",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),

          ::PubidNew::Components::TypedStage.new(
            code: :dtr,
            stage_code: :draft,
            type_code: :tr,
            abbr: ["DTR"],
            name: "Draft Technical Report",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),
          ::PubidNew::Components::TypedStage.new(
            code: :fdtr,
            stage_code: :final_draft,
            type_code: :tr,
            abbr: ["FDTR"],
            name: "Final Draft Technical Report",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          ::PubidNew::Components::TypedStage.new(
            code: :prftr,
            stage_code: :prf,
            type_code: :tr,
            abbr: ["PRF TR"],
            name: "Proof Technical Report",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          ::PubidNew::Components::TypedStage.new(
            code: :pubtr,
            stage_code: :published,
            type_code: :tr,
            abbr: ["TR"],
            name: "Published Technical Report",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :tr, title: "Technical Report", short: "TR" }
        end
      end
    end
  end
end
