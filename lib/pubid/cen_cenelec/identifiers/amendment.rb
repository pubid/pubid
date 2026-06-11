# frozen_string_literal: true

module Pubid
  module CenCenelec
    module Identifiers
      # Amendment Identifier
      # Contains a base identifier plus amendment parameters
      class Amendment < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :amendment_number, :string
        attribute :amendment_year, :integer

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
