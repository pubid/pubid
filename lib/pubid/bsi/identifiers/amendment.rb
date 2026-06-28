# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Amendment Identifier
      # Contains a base identifier plus amendment parameters
      class Amendment < SingleIdentifier
        attribute :base_identifier, ::Pubid::Identifier, polymorphic: true
        attribute :amendment_number, :string
        attribute :amendment_year, :integer
        attribute :separator, :string, default: -> { "+" }

        def publisher
          base_identifier&.publisher
        end
      end
    end
  end
end
