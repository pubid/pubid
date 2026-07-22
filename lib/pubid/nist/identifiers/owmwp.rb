# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NIST OWMWP (Office of Weights and Measures Workshop Proceedings)
      # Examples:
      # - "NIST OWMWP 06-13-2018" - Date-based format MM-DD-YYYY
      class Owmwp < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["OWMWP", "NIST OWMWP"],
            stage_code: "published",
            type_code: "owmwp",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :owmwp,
              title: "Office of Weights and Measures Workshop Proceedings", short: "OWMWP" }
          end
        end

        def series_code
          "OWMWP"
        end
      end
    end
  end
end
