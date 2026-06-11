# frozen_string_literal: true

module Pubid
  module CenCenelec
    module Identifiers
      # Corrigendum Identifier
      # Contains a base identifier plus corrigendum parameters
      class Corrigendum < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :corrigendum_number, :string
        attribute :corrigendum_year, :integer
        attribute :corrigendum_month, :string

        def to_s(**opts)
          render(format: :human, **opts)
        end

        def publisher
          base_identifier&.publisher
        end
      end
    end
  end
end
