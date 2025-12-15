# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Astm
    module Components
      class Code < Lutaml::Model::Serializable
        attribute :letter, :string       # A-G for standards
        attribute :number, :string       # Main number
        attribute :suffix, :string       # A, B, C for data series
        attribute :subseries, :string    # S1, S4, S10 for data series
        attribute :dual_m, :boolean      # M suffix for metric (dual unit)

        def to_s
          return number.to_s unless letter

          parts = [letter, number]
          parts << suffix if suffix
          result = parts.join
          result += "-S#{subseries}" if subseries
          result += "M" if dual_m
          result
        end
      end
    end
  end
end