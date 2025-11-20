# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Itu
    module Components
      # ITU Sector component
      # Values: R (Radio), T (Telecommunications), D (Development)
      class Sector < Lutaml::Model::Serializable
        attribute :sector, :string  # R, T, or D

        VALID_SECTORS = %w[R T D].freeze

        def initialize(sector:)
          unless VALID_SECTORS.include?(sector.to_s.upcase)
            raise ArgumentError, "Invalid sector: #{sector}. Must be R, T, or D"
          end
          @sector = sector.to_s.upcase
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