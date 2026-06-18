# frozen_string_literal: true

module Pubid
  module Sae
    module Identifiers
      # Base SAE Identifier
      # Handles all SAE document types (AMS, AIR, ARP, AS, MA)
      class Base < Pubid::Identifier
        # Generate URN for this identifier
        #
        # @return [String] URN representation

        attribute :publisher, :string, default: -> { "SAE" }
        attribute :type, Sae::Components::Type
        attribute :number, Sae::Components::Code
        attribute :date, Sae::Components::Date

        def year
          date&.year
        end
      end
    end
  end
end
