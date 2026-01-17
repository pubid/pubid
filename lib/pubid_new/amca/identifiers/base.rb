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
        attribute :copublisher, :string
        attribute :code, Components::Code
        attribute :year, Components::Date
        attribute :suffix, :string
        attribute :reaffirmed, :string

        def self.parse(string)
          Amca::Identifier.parse(string)
        end
      end
    end
  end
end
