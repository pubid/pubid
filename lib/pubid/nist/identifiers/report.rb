# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NBS RPT (Report) Identifier
      # Examples:
      # - "NBS RPT 8079" - Basic report
      # - "NBS RPT 9350sup" - Report with supplement
      # - "NBS RPT Oct-Dec1950" - Report with date range
      # - "NBS RPT ADHOC" - Ad hoc report
      # - "NBS RPT div9" - Division report
      # - "NBS RPT 4817-A" - Report with letter suffix
      class Report < Base
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["RPT", "NBS RPT"],
            stage_code: "published",
            type_code: "rpt",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :rpt,
            web: :report, title: "NBS Report", short: "RPT" }
          end
        end

        def default_publisher
          "NBS"
        end

        def series_code
          "RPT"
        end

        def to_s(format = :short)
          case format
          when :mr
            to_mr_style
          else
            to_short_style
          end
        end

        private

        def to_short_style
          result = "#{default_publisher} #{series_code}"
          result += " #{number}" if number
          result += append_short_components
          result
        end

        def to_mr_style
          result = "#{default_publisher}.#{series_code}"
          result += ".#{number}" if number
          result += append_mr_components
          result
        end
      end
    end
  end
end
