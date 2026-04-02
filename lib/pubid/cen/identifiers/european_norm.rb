# frozen_string_literal: true


module Pubid
  module Cen
    module Identifiers
      # European Norm (EN) identifier
      class EuropeanNorm < SingleIdentifier
        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :puben,
            stage_code: :published,
            type_code: :en,
            abbr: ["EN"],
            name: "European Norm",
            harmonized_stages: %w[60.00 60.60],
          ),
          Components::TypedStage.new(
            code: :pren,
            stage_code: :proposal,
            type_code: :en,
            abbr: ["prEN"],
            name: "Proposal European Norm",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.98 30.99],
          ),
          Components::TypedStage.new(
            code: :fpren,
            stage_code: :final_proposal,
            type_code: :en,
            abbr: ["FprEN"],
            name: "Final Proposal European Norm",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.98 40.99],
          ),
        ].freeze

        def self.type
          { key: :en, title: "European Norm", short: "EN" }
        end
      end
    end
  end
end
