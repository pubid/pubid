# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NBS/NIST CS (Commercial Standard)
      # Distinct from CS-E (emergency) and CSM (monthly)
      # Examples:
      # - "NBS CS 102" - Basic commercial standard
      # - "NBS CS 102E-42" - With letter suffix and number
      # - "CS 190-58" - With year
      class CommercialStandard < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["CS", "NBS CS"],
            stage_code: "published",
            type_code: "cs",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :cs,
            web: :commercial_standard, title: "Commercial Standard", short: "CS" }
          end
        end

        def default_publisher
          "NBS"
        end

        def series_code
          "CS"
        end
      end
    end
  end
end
