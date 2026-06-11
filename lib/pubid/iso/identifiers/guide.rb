# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      class Guide < SingleIdentifier

        TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :pwiis,
            stage_code: :pwi,
            type_code: :guide,
            abbr: ["PWI Guide"],
            name: "Proposed Work Item for International Standard",
            harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :npguide,
            stage_code: :np,
            type_code: :guide,
            abbr: ["NP Guide", "NP GUIDE"],
            name: "New Work Item Proposal for Guide",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98 10.99],
          ),

          ::Pubid::Components::TypedStage.new(
            code: :awiguide,
            stage_code: :awi,
            type_code: :guide,
            abbr: ["AWI Guide", "AWI GUIDE"],
            name: "Approved Work Item for Guide",
            harmonized_stages: %w[10.99 20.00],
          ),

          ::Pubid::Components::TypedStage.new(
            code: :wdguide,
            stage_code: :wd,
            type_code: :guide,
            abbr: ["WD Guide", "WD GUIDE"],
            name: "Working Draft for Guide",
            harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
          ),

          ::Pubid::Components::TypedStage.new(
            code: :cdguide,
            stage_code: :cd,
            type_code: :guide,
            abbr: ["CD Guide", "CD GUIDE"],
            name: "Committee Draft for Guide",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),

          ::Pubid::Components::TypedStage.new(
            code: :dguide,
            stage_code: :dguide,
            type_code: :guide,
            abbr: ["DGuide", "DGUIDE"],
            name: "Draft Guide",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :fdguide,
            stage_code: :fdguide,
            type_code: :guide,
            abbr: ["FDGuide", "FD Guide", "FD GUIDE"],
            name: "Final Draft Guide",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :prfguide,
            stage_code: :prf,
            type_code: :guide,
            abbr: ["PRF Guide", "PRF GUIDE"],
            name: "Proof Guide",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :pubguide,
            stage_code: :published,
            type_code: :guide,
            abbr: ["Guide", "GUIDE"],
            name: "Published Guide",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :guide, title: "Guide", short: "GUIDE" }
        end

        def to_s(**opts)
          context = build_rendering_context(nil, format: :human, **opts)
          Pubid::Renderers::GuideRenderer.new(self).render(context:,
                                                           **opts.slice(:with_edition))
        end
      end
    end
  end
end
