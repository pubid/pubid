# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Itu
    module Components
      # ITU Sector component
      # Values: R (Radio), T (Telecommunications), D (Development)
      class Sector < Lutaml::Model::Serializable
        attribute :sector, :string # R, T, or D

        VALID_SECTORS = %w[R T D].freeze

        # Optional arg + `super()` + setter so the attribute is lutaml-tracked
        # and round-trips through to_hash/from_hash (lutaml deserializes via an
        # argless `.new` then attribute assignment).
        def initialize(sector: nil, **opts)
          super(**opts)
          return if sector.nil?

          normalized = sector.to_s.upcase
          unless VALID_SECTORS.include?(normalized)
            raise ArgumentError, "Invalid sector: #{sector}. Must be R, T, or D"
          end

          self.sector = normalized
        end

        def to_s
          sector
        end

        def ==(other)
          return false unless other.is_a?(Sector)

          sector == other.sector
        end
      end
    end
  end
end
