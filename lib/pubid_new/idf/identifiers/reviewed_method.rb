require_relative "../identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Idf
    module Identifiers
      class ReviewedMethod < Identifier
        attribute :type, Components::Type, default: -> { type[:key] }
        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pwirm,
            stage_code: :pwi,
            type_code: :rm,
            abbr: ["PWI RM"],
            name: "Proposed Work Item for Reviewed Method",
            harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
          ),
          Components::TypedStage.new(
            code: :nprm,
            stage_code: :np,
            type_code: :rm,
            abbr: ["NP RM"],
            name: "New Work Item Proposal for Reviewed Method",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
          ),

          Components::TypedStage.new(
            code: :awirm,
            stage_code: :awi,
            type_code: :rm,
            abbr: ["AWI RM"],
            name: "Approved Work Item for Reviewed Method",
            harmonized_stages: %w[10.99 20.00],
          ),

          Components::TypedStage.new(
            code: :wdrm,
            stage_code: :wd,
            type_code: :rm,
            abbr: ["WD RM"],
            name: "Working Draft Reviewed Method",
            harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
          ),

          Components::TypedStage.new(
            code: :cdrm,
            stage_code: :cd,
            type_code: :rm,
            abbr: ["CD RM"],
            name: "Committee Draft Reviewed Method",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),
          Components::TypedStage.new(
            code: :pdrm,
            stage_code: :cd,
            type_code: :rm,
            abbr: ["PDRM"],
            name: "Proposed Draft Reviewed Method",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),

          Components::TypedStage.new(
            code: :drm,
            type_code: :rm,
            abbr: ["DRM"],
            name: "Draft Reviewed Method",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),
          Components::TypedStage.new(
            code: :fdrm,
            type_code: :rm,
            abbr: ["FDRM"],
            name: "Final Draft Reviewed Method",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),

          Components::TypedStage.new(
            code: :prfrm,
            stage_code: :prf,
            type_code: :rm,
            abbr: ["PRF RM"],
            name: "Proof Reviewed Method",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          Components::TypedStage.new(
            code: :pubrm,
            stage_code: :published,
            type_code: :rm,
            abbr: ["RM"],
            name: "Published Reviewed Method",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :rm, title: "Reviewed Method", short: "RM" }
        end
      end
    end
  end
end
