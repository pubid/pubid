# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Cen
    module Identifiers
      # Amendment Identifier
      # Contains a base identifier plus amendment parameters
      class Amendment < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :amendment_number, :string
        attribute :amendment_year, :integer

        def to_s
          if base_identifier
            result = "#{base_identifier.to_s}/A#{amendment_number}"
            result += ":#{amendment_year}" if amendment_year
            result
          else
            result = "/A#{amendment_number}"
            result += ":#{amendment_year}" if amendment_year
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