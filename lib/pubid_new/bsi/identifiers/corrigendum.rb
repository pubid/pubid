# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # Corrigendum Identifier
      # Contains a base identifier plus corrigendum parameters
      class Corrigendum < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :corrigendum_number, :string
        attribute :corrigendum_year, :integer

        def to_s
          if base_identifier
            "#{base_identifier.to_s}+C#{corrigendum_number}:#{corrigendum_year}"
          else
            "+C#{corrigendum_number}:#{corrigendum_year}"
          end
        end

        def publisher
          base_identifier&.publisher
        end
      end
    end
  end
end