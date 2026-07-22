# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # Errata identifier (Err.)
      # Pattern: "ITU-T G.9701 (2014) Err. 1 (07/2016)"
      class Errata < Supplement
        def to_s
          result = base ? base.to_s : "#{publisher}-#{sector}"

          if !base && series
            result += " #{series}"
          end

          result += " Err. #{number}"

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
          return false unless other.is_a?(Errata)

          base == other.base &&
            number == other.number &&
            date == other.date
        end
      end
    end
  end
end
