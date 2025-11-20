# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Cen
    module Identifiers
      # Corrigendum Identifier
      # Contains a base identifier plus corrigendum parameters
      class Corrigendum < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :corrigendum_number, :string
        attribute :corrigendum_year, :integer

        def to_s
          if base_identifier
            result = base_identifier.to_s
            result += "+AC"
            result += corrigendum_number if corrigendum_number && !corrigendum_number.empty?
            result += ":#{corrigendum_year}" if corrigendum_year
            result
          else
            "+AC#{corrigendum_number}:#{corrigendum_year}"
          end
        end

        def publisher
          base_identifier&.publisher
        end
      end
    end
  end
end