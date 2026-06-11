# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      # International Standardized Profile Identifier
      class InternationalStandardizedProfile < SingleIdentifier

        TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :pwiisp,
            stage_code: :pwi,
            type_code: :isp,
            abbr: ["PWI ISP"],
            name: "Proposed Work Item for International Standardized Profile",
            harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :npisp,
            stage_code: :np,
            type_code: :isp,
            abbr: ["NP ISP"],
            name: "New Work Item Proposal for International Standardized Profile",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :awiisp,
            stage_code: :awi,
            type_code: :isp,
            abbr: ["AWI ISP"],
            name: "Approved Work Item for International Standardized Profile",
            harmonized_stages: %w[10.99 20.00],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :wdisp,
            stage_code: :wd,
            type_code: :isp,
            abbr: ["WD ISP"],
            name: "Working Draft for International Standardized Profile",
            harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :cdisp,
            stage_code: :cd,
            type_code: :isp,
            abbr: ["CD ISP"],
            name: "Committee Draft for International Standardized Profile",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :disp,
            stage_code: :disp,
            type_code: :isp,
            abbr: ["DISP"],
            name: "Draft International Standardized Profile",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),

          ::Pubid::Components::TypedStage.new(
            code: :fdisp,
            stage_code: :fdis,
            type_code: :isp,
            abbr: ["FDISP"],
            name: "Final Draft International Standardized Profile",
            harmonized_stages: %w[50.00 50.20 50.60 50.92],
          ),

          ::Pubid::Components::TypedStage.new(
            code: :prfisp,
            stage_code: :prf,
            type_code: :isp,
            abbr: ["PRF ISP"],
            name: "Proof International Standardized Profile",
            harmonized_stages: %w[60.00],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :isp,
            stage_code: :published,
            type_code: :isp,
            abbr: ["ISP"],
            name: "International Standardized Profile",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :isp, title: "International Standardized Profile",
            short: "ISP" }
        end
      end
    end
  end
end
