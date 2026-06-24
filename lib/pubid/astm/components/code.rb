# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Astm
    module Components
      # Code component for ASTM identifiers.
      #
      # Stays independent of Pubid::Components::Code because ASTM has a
      # rich taxonomy: +letter+ (A-G for standards), +suffix+ (A/B/C for
      # data series), +subseries+ (S1/S4/S10), and +dual_m+ (metric flag).
      class Code < Lutaml::Model::Serializable
        attribute :letter, :string       # A-G for standards
        attribute :number, :string       # Main number
        attribute :suffix, :string       # A, B, C for data series
        attribute :subseries, :string    # S1, S4, S10 for data series
        attribute :dual_m, :boolean      # M suffix for metric (dual unit)

        def to_s
          if letter
            parts = [letter, number]
            parts << suffix if suffix
            result = parts.join
            result += "-S#{subseries}" if subseries
            result += "M" if dual_m
          else
            # No letter (e.g., DataSeries, ISO/ASTM dual)
            result = number.to_s
            result += suffix if suffix
            result += "-S#{subseries}" if subseries
          end
          result
        end

        def render(context: nil)
          to_s
        end
      end
    end
  end
end
