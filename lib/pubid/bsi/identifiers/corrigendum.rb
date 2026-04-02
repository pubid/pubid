# frozen_string_literal: true


module Pubid
  module Bsi
    module Identifiers
      # Corrigendum Identifier
      # Contains a base identifier plus corrigendum parameters
      class Corrigendum < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :corrigendum_number, :string
        attribute :corrigendum_year, :integer
        attribute :separator, :string, default: -> { "+" }

        def to_s
          result = base_identifier ? base_identifier.to_s : ""
          result += "#{separator}C"
          result += corrigendum_number.to_s if corrigendum_number
          result += ":#{corrigendum_year}" if corrigendum_year
          result
        end

        def publisher
          base_identifier&.publisher
        end
      end
    end
  end
end
