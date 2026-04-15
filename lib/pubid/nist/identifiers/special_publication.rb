# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NIST Special Publication (SP)
      # Examples:
      # - "NIST SP 800-53" = Special Publication 800-53
      # - "NIST SP 800-53r5" = Special Publication 800-53 revision 5
      # - "NIST SP 800-57pt1r4" = Special Publication 800-57 part 1 revision 4
      class SpecialPublication < Base
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["SP", "NIST SP", "NBS SP"], # Compound series
            stage_code: "published",
            type_code: "sp",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :sp, title: "NIST Special Publication", short: "SP" }
          end
        end

        def series_code
          "SP"
        end
      end
    end
  end
end
