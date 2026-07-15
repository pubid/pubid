# frozen_string_literal: true

module Pubid
  module Jcgm
    module Identifiers
      # A JCGM corrigendum, e.g. "JCGM 200:2008 Corrigendum" — a guide carrying
      # a trailing " Corrigendum" marker (no iteration number). Mirrors
      # Amendment but with a space-separated word suffix instead of "/Amd N".
      class Corrigendum < SupplementIdentifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubcorr,
            stage_code: :published,
            type_code: :corrigendum,
            abbr: ["Corrigendum"],
            name: "Corrigendum",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :corrigendum, title: "Corrigendum", short: "Corr" }
        end
      end
    end
  end
end
