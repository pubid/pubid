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

        def to_s
          if base_identifier
            "#{base_identifier.to_s}+A#{amendment_number}:#{amendment_year}"
          else
            "+A#{amendment_number}:#{amendment_year}"
          end
        end

        def publisher
          base_identifier&.publisher
        end
      end
    end
  end
end