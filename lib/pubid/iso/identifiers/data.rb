# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      # Data Identifier
      class Data < SingleIdentifier

        TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :npdata,
            stage_code: :np,
            type_code: :data,
            abbr: ["NP DATA"],
            name: "New Work Item Proposal for Data",
            harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :awidata,
            stage_code: :awi,
            type_code: :data,
            abbr: ["AWI DATA"],
            name: "Approved Work Item for Data",
            harmonized_stages: %w[10.99 20.00],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :wddata,
            stage_code: :wd,
            type_code: :data,
            abbr: ["WD DATA"],
            name: "Working Draft for Data",
            harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :cddata,
            stage_code: :cd,
            type_code: :data,
            abbr: ["CD DATA"],
            name: "Committee Draft for Data",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :ddata,
            stage_code: :ddata,
            type_code: :data,
            abbr: ["D DATA"],
            name: "Draft Data",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),

          ::Pubid::Components::TypedStage.new(
            code: :prfdata,
            stage_code: :prf,
            type_code: :data,
            abbr: ["PRF DATA"],
            name: "Proof Data",
            harmonized_stages: %w[60.00],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :pubdata,
            stage_code: :published,
            type_code: :data,
            abbr: ["DATA"],
            name: "Data",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :data, title: "Data", short: "PAS" }
        end
      end
    end
  end
end
