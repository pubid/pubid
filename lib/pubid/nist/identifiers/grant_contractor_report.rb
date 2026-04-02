# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NIST Grant/Contractor Report (GCR)
      # Examples:
      # - "NIST GCR 17-917-45" - Basic 3-part number
      # - "NIST GCR 21-917-48v3B" - With volume and letter suffix
      class GrantContractorReport < Base
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["GCR", "NIST GCR"],
            stage_code: "published",
            type_code: "gcr"
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :gcr, title: "NIST Grant/Contractor Report", short: "GCR" }
          end
        end

        def series_code
          "GCR"
        end
      end
    end
  end
end
