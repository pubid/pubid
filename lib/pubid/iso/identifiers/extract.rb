# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      class Extract < SupplementIdentifier

        TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :pubext,
            stage_code: :published,
            type_code: :ext,
            abbr: ["Ext"],
            name: "Extract",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :ext, title: "Extract", short: "Ext" }
        end

        # def self.get_renderer_class
        #   Renderer::TechnologyTrendsAssessments
        # end
      end
    end
  end
end
