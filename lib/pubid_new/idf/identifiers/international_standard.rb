require_relative "../single_identifier"
# frozen_string_literal: true
require_relative "../../components/typed_stage"

module PubidNew
  module Idf
    module Identifiers
      # International Standard Identifier
      class InternationalStandard < SingleIdentifier
        attribute :type, Components::Type, default: -> { self.class.type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pwiis,
            stage_code: :pwi,
            type_code: :is,
            abbr: ["PWI"],
            name: "Proposed Work Item for International Standard",
            harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
          ),
          Components::TypedStage.new(
            code: :isnp,
            stage_code: :np,
            type_code: :is,
            abbr: ["NP", "NWIP"],
            name: "New Work Item Proposal for International Standard",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
          ),
          Components::TypedStage.new(
            code: :awiis,
            stage_code: :awi,
            type_code: :is,
            abbr: ["AWI"],
            name: "Approved Work Item for International Standard",
            harmonized_stages: %w[10.99 20.00],
          ),
          Components::TypedStage.new(
            code: :wdis,
            stage_code: :wd,
            type_code: :is,
            abbr: ["WD"],
            name: "Working Draft for International Standard",
            harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
          ),
          Components::TypedStage.new(
            code: :cdis,
            stage_code: :cd,
            type_code: :is,
            abbr: ["CD"],
            name: "Committee Draft for International Standard",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),
          Components::TypedStage.new(
            code: :fcdis,
            stage_code: :fcd,
            type_code: :is,
            abbr: ["FCD"],
            name: "Final Committee Draft for International Standard",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),
          Components::TypedStage.new(
            code: :dis,
            stage_code: :dis,
            type_code: :is,
            abbr: ["DIS", "FPD"],
            name: "Draft International Standard",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),
          Components::TypedStage.new(
            code: :fdis,
            stage_code: :fdis,
            type_code: :is,
            abbr: ["FDIS"],
            name: "Final Draft International Standard",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          Components::TypedStage.new(
            code: :prfis,
            stage_code: :prf,
            type_code: :is,
            abbr: ["PRF", "Fpr"],
            name: "Proof International Standard",
            harmonized_stages: %w[60.00],
          ),
          Components::TypedStage.new(
            code: :is,
            stage_code: :published,
            type_code: :is,
            abbr: [""],
            name: "International Standard",
            harmonized_stages: %w[60.00 60.60],
          ),
          Components::TypedStage.new(
            code: :wdr,
            stage_code: :wdr,
            type_code: :is,
            abbr: ["WDR"],
            name: "Proposed for Withdrawal",
            harmonized_stages: %w[90.92],
          ),
          Components::TypedStage.new(
            code: :wda,
            stage_code: :wda,
            type_code: :is,
            abbr: ["WDA"],
            name: "Withdrawal Approved",
            harmonized_stages: %w[90.93],
          ),
          Components::TypedStage.new(
            code: :wdar,
            stage_code: :wdar,
            type_code: :is,
            abbr: ["WDAR"],
            name: "Withdrawal Archived",
            harmonized_stages: %w[95.99],
          ),
        ].freeze

        def self.type
          { key: :is, title: "International Standard", short: nil }
        end
      end
    end
  end
end
