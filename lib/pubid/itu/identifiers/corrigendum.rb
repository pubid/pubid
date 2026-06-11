# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # Corrigendum identifier (Cor.)
      # Pattern: "ITU-T Z.100 (1999) Cor. 1 (10/2001)"
      # Can be corrigendum of annex: "ITU-T G.729 Annex E (1998) Cor. 1 (02/2000)"
      class Corrigendum < Supplement
        def to_s
          result = base ? base.to_s : "#{publisher}-#{sector}"

          # Add series if no base
          if !base && series
            result += " #{series}"
          end

          result += " Cor. #{number}"

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
          return false unless other.is_a?(Corrigendum)

          base == other.base &&
            number == other.number &&
            date == other.date
        end
      end
    end
  end
end
