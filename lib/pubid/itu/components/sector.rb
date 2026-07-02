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

        # Accept either a positional Hash (lutaml-model's call style:
        # `Sector.new({lutaml_register: :default})` then attribute assignment)
        # or a literal `sector:` kwarg (`Sector.new(sector: "R")`). Both call
        # paths funnel through the same validate-then-set flow so the attribute
        # stays lutaml-tracked and round-trips through to_hash/from_hash.
        def initialize(attrs = {}, options = {})
          super
          sector_val = attrs[:sector] || attrs["sector"]
          return if sector_val.nil?

          normalized = sector_val.to_s.upcase
          unless VALID_SECTORS.include?(normalized)
            raise ArgumentError,
                  "Invalid sector: #{sector_val}. Must be R, T, or D"
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
