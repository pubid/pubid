# frozen_string_literal: true

module Pubid
  module Amca
    module Identifiers
      # Base identifier class for ACMA identifiers
      # Single Responsibility: Common functionality for all ACMA identifier types
      class Base < Lutaml::Model::Serializable
        include Pubid::Serializable

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

        # Render the identifier as a string
        def to_s
          parts = []
          parts << copublisher if copublisher
          # type is a hash, get the title
          if respond_to?(:type) && type.is_a?(Hash) && type[:title]
            parts << type[:title].to_s
          end
          parts << code.to_s
          parts << "-#{year}" if year

          result = parts.compact.join(" ")

          # Handle additional copublisher after year (e.g., /ASHRAE 51-16)
          if copublisher&.include?("/") && year
            type_title = respond_to?(:type) && type.is_a?(Hash) ? type[:title].to_s : ""
            result = "#{copublisher} #{type_title} #{code}-#{year}"
          end

          result += " (#{reaffirmed})" if reaffirmed

          result
        end

        def self.parse(string)
          Amca::Identifier.parse(string)
        end

        def to_urn
          require_relative "../urn_generator"
          UrnGenerator.new(self).generate
        end
      end
    end
  end
end
