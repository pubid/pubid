# frozen_string_literal: true

module Pubid
  module Sae
    module Identifiers
      # Base SAE Identifier
      # Handles all SAE document types (AMS, AIR, ARP, AS, MA)
      class Base < Lutaml::Model::Serializable
        # Generate URN for this identifier
        #
        # @return [String] URN representation

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
