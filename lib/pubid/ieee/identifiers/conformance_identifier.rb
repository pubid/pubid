# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Conformance identifier for IEEE standards
      # Represents conformance test documents
      # Example: IEEE Std 802.16/Conformance01-2003
      class ConformanceIdentifier < SupplementIdentifier
        attribute :conf_number, :string
        attribute :conf_year, :string

        # TYPED_STAGES for conformance
        # Conformance uses "Conformance" abbreviation
        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["Conformance"],
            type_code: "conformance",
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
