# frozen_string_literal: true

require_relative "base"

module PubidNew
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
          result += " #{number.to_s}" if number
          result += "sup#{supplement}" if supplement && !supplement.empty?
          result += "sup" if supplement == ""
          result
        end

        def to_mr_style
          result = "#{default_publisher}.#{series_code}"
          result += ".#{number}" if number
          result
        end
      end
    end
  end
end