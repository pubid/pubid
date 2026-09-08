# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # White Paper identifier class
      # Single Responsibility: Represents IEC White Paper documents
      class WhitePaper < Base
        # White Papers have full phrase as type abbreviation
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :wp,
            stage_code: :published,
            type_code: :wp,
            abbr: ["White Paper"],
            name: "White Paper",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :wp,
            web: :white_paper, title: "White Paper", short: "White Paper" }
        end

      end
    end
  end
end
