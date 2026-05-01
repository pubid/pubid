# frozen_string_literal: true

require_relative "base"

module Pubid
  module Itu
    module Identifiers
      # ITU Special Publication — currently models the Operational Bulletin (OB).
      # OB is a cross-bureau publication (no sector) rendered as
      # "ITU OB No. {number}" with optional date.
      #
      # Pattern: "ITU OB No. 1283 (01/2024)"
      class SpecialPublication < Base
        def render_base(**_opts)
          number = code&.number
          result = "#{publisher} #{series} No. #{number}"

          if date
            result += if date.month
                        " (#{date.month.to_s.rjust(2, '0')}/#{date.year})"
                      else
                        " (#{date.year})"
                      end
          end

          result
        end
      end
    end
  end
end
