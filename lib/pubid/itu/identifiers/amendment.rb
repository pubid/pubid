# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # Amendment identifier (Amd)
      # Pattern: "ITU-T G.989 Amd 1", "ITU-T G.780/Y.1351 Amd 1 (2004)"
      class Amendment < Supplement
        def to_s
          result = base ? base.to_s : "#{publisher}-#{sector}"

          # Add series if no base
          if !base && series
            result += " #{series}"
          end

          result += " Amd #{number}"

          # Add date if present
          if date
            result += if date.month
                        " (#{date.month}/#{date.year})"
                      else
                        " (#{date.year})"
                      end
          end

          result
        end

        def ==(other)
          return false unless other.is_a?(Amendment)

          base == other.base &&
            number == other.number &&
            date == other.date
        end
      end
    end
  end
end
