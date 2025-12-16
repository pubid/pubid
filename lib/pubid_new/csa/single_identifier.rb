# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Csa
    class SingleIdentifier < Lutaml::Model::Serializable
      attribute :code, Components::Code
      attribute :no_number, :string
      attribute :year, :string
      attribute :french, :boolean
      attribute :reaffirmation, :string
    end
  end
end