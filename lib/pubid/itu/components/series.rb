# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Itu
    module Components
      # ITU Series component
      # Examples: BO, V, X, A, etc.
      class Series < Lutaml::Model::Serializable
        attribute :series, :string # e.g., BO, V, X, R, SG1, OB

        def to_s
          series
        end

        def ==(other)
          return false unless other.is_a?(Series)

          series == other.series
        end
      end
    end
  end
end
