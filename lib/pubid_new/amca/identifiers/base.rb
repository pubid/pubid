# frozen_string_literal: true

require "lutaml/model"
require_relative "../../components/code"
require_relative "../../components/date"

module PubidNew
  module Amca
    module Identifiers
      # Base identifier class for ACMA identifiers
      # Single Responsibility: Common functionality for all ACMA identifier types
      class Base < Lutaml::Model::Serializable
        include PubidNew::Serializable

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
          if respond_to?(:type) && type.is_a?(Hash)
            parts << type[:title].to_s if type[:title]
          end
          parts << code.to_s
          parts << "-#{year}" if year

          result = parts.compact.join(" ")

          # Handle additional copublisher after year (e.g., /ASHRAE 51-16)
          if copublisher && copublisher.include?("/") && year
            type_title = respond_to?(:type) && type.is_a?(Hash) ? type[:title].to_s : ''
            result = "#{copublisher} #{type_title} #{code}-#{year}"
          end

          result += " (#{reaffirmed})" if reaffirmed

          result
        end

        def self.parse(string)
          Amca::Identifier.parse(string)
        end
      end
    end
  end
end
