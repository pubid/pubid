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
        attribute :corrigendum_month, :string

        def to_s
          if base_identifier
            result = base_identifier.to_s
            result += "/AC"
            result += corrigendum_number if corrigendum_number && !corrigendum_number.empty?
            if corrigendum_year
              result += ":#{corrigendum_year}"
              result += "-#{corrigendum_month}" if corrigendum_month && !corrigendum_month.empty?
            end
            result
          else
            result = "/AC#{corrigendum_number}"
            if corrigendum_year
              result += ":#{corrigendum_year}"
              result += "-#{corrigendum_month}" if corrigendum_month && !corrigendum_month.empty?
            end
            result
          end
        end

        def publisher
          base_identifier&.publisher
        end
      end
    end
  end
end