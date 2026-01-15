# frozen_string_literal: true

require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Nist
    module Identifiers
      # NBS LC (Letter Circular)
      # Examples:
      # - "NBS LC 378" - Basic letter circular
      # - "NBS LCIRC 378g" - With LCIRC variant, letter suffix
      # - "NBS LC 378G" - Letter suffix uppercase
      # - "NBS LC 378sup12/1926" - With supplement date
      # - "NBS LC 378r11/1925" - With revision date
      # - "NBS LC 378(sp)" - With language code
      class LetterCircular < Base
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            abbr: ["LC", "LCIRC", "NBS LC", "NBS LCIRC"],
            stage_code: "published",
            type_code: "lc"
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :lc, title: "Letter Circular", short: "LC" }
          end
        end

        def default_publisher
          "NBS"
        end

        def series_code
          "LC"
        end
      end
    end
  end
end
