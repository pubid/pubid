# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # Amendment Identifier
      # Contains a base identifier plus amendment parameters
      class Amendment < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :amendment_number, :string
        attribute :amendment_year, :integer
        attribute :separator, :string, default: -> { "+" }

        def to_s
          if base_identifier
            if amendment_year
              "#{base_identifier}#{separator}A#{amendment_number}:#{amendment_year}"
            else
              # Letter suffixes (AA, AB, etc.) have a space, numeric suffixes don't
              if amendment_number&.match?(/^[A-Z]+$/)
                "#{base_identifier} AMD #{amendment_number}"
              else
                "#{base_identifier} AMD#{amendment_number}"
              end
            end
          else
            if amendment_year
              "#{separator}A#{amendment_number}:#{amendment_year}"
            else
              # Letter suffixes (AA, AB, etc.) have a space, numeric suffixes don't
              if amendment_number&.match?(/^[A-Z]+$/)
                "AMD #{amendment_number}"
              else
                "AMD#{amendment_number}"
              end
            end
          end
        end

        def publisher
          base_identifier&.publisher
        end
      end
    end
  end
end
