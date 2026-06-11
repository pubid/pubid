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

        def to_s
          render(format: :human)
        end
      end
    end
  end
end
