# frozen_string_literal: true

module Pubid
  module Amca
    module Identifiers
      # Base identifier class for ACMA identifiers
      # Single Responsibility: Common functionality for all ACMA identifier types
      class Base < Pubid::Identifier
        # Override base_hash to handle AMCA-specific copublisher format (string, not array)
        def base_hash
          hash = super
          # AMCA's copublisher is a string, not an array, so remove it from copublishers
          hash.delete(:copublishers) if hash[:copublishers]
          hash
        end

        attribute :copublisher, :string
        attribute :code, Components::Code
        attribute :year, Components::Date
        attribute :suffix, :string
        attribute :reaffirmed, :string

        # AMCA uses a fixed publisher string
        def publisher
          "AMCA"
        end

        def self.parse(string)
          Amca::Identifier.parse(string)
        end

        def to_urn
          UrnGenerator.new(self).generate
        end
      end
    end
  end
end
