# frozen_string_literal: true

require "lutaml/model"
require_relative "parser"
require_relative "builder"

module PubidNew
  module Cie
    # Base Identifier class for CIE
    # Provides parse() entry point
    class Identifier < Lutaml::Model::Serializable
      attribute :style, :string  # "legacy" or "current"

      # Parse CIE identifier string
      def self.parse(input)
        require_relative "identifiers/standard"  # Ensure loaded

        parsed = Parser.parse(input)
        builder = Builder.new
        builder.build(parsed, original_string: input)
      end
    end
  end
end
