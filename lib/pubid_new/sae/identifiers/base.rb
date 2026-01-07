# frozen_string_literal: true

require "lutaml/model"
require_relative "../components/code"
require_relative "../components/date"
require_relative "../components/type"

module PubidNew
  module Sae
    module Identifiers
      # Base SAE Identifier
      # Handles all SAE document types (AMS, AIR, ARP, AS, MA)
      class Base < Lutaml::Model::Serializable
        attribute :publisher, :string, default: -> { "SAE" }
        attribute :type, Sae::Components::Type
        attribute :number, Sae::Components::Code
        attribute :date, Sae::Components::Date

        def to_s
          parts = []

          # Publisher and type
          parts << publisher if publisher
          parts << type.to_s if type

          # Number
          parts << number.to_s if number

          result = parts.join(" ")

          # Date
          result += ":#{date.year}" if date

          result
        end

        def year
          date&.year
        end
      end
    end
  end
end