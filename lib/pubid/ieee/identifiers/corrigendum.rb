# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Corrigendum identifier for IEEE standards
      # Represents corrections to published standards
      # Example: IEEE Std 535-2013/Cor. 1-2017
      class Corrigendum < SupplementIdentifier
        attribute :cor_number, :string
        attribute :cor_year, :string

        # TYPED_STAGES for corrigendum
        # Corrigendum uses "Cor" abbreviation
        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["Cor"],
            type_code: "corrigendum",
            stage_code: "published",
          ),
        ].freeze

        # MR supplement suffix: `cor.{number}.{year}` (e.g. "/cor.1.2017").
        # The MrString renderer recurses into `base` and appends this so the
        # full IEEE corrigendum round-trips losslessly (issue #142).
        def mr_supplement_suffix
          segments = []
          segments << "cor"
          segments << cor_number.to_s if cor_number
          segments << cor_year.to_s if cor_year
          segments.join(".")
        end
      end
    end
  end
end
