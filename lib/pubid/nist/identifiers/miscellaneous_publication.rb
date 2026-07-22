# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NBS MP (Miscellaneous Publication) Identifier
      # Examples:
      # - "NBS MP 39e1" - Edition with "e" notation
      # - "NBS MP 260e1965" - Edition with year as edition ID
      # NOTE: Parenthetical edition format (e.g., "39(1)") does NOT exist for MP identifiers
      class MiscellaneousPublication < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["MP", "NBS MP"],
            stage_code: "published",
            type_code: "mp",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :mp,
            web: :miscellaneous_publication, title: "Miscellaneous Publication", short: "MP" }
          end
        end

        def default_publisher
          "NBS"
        end

        def series_code
          "MP"
        end

        def to_s(format = :short)
          case format
          when :mr
            to_mr_style
          else
            to_short_style
          end
        end

        public

        def to_short_style
          result = "#{default_publisher} #{series_code}"
          result += " #{number.value}" if number
          result += append_short_components
          result
        end

        def to_mr_style
          result = "#{default_publisher}.#{series_code}"
          result += ".#{number.value}" if number
          result += append_mr_components
          result
        end
      end
    end
  end
end
