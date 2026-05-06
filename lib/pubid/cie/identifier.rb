# frozen_string_literal: true


module Pubid
  module Cie
    # Base Identifier class for CIE
    # Provides parse() entry point
    class Identifier < Lutaml::Model::Serializable
      attribute :style, :string # "legacy" or "current"

      # Parse CIE identifier string
      def self.parse(input)
        parsed = Parser.parse(input)
        builder = Builder.new
        builder.build(parsed, original_string: input)
      end
    end
  end
end
