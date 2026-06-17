# frozen_string_literal: true

module Pubid
  module Cie
    # Base Identifier class for CIE.
    #
    # Inherits the shared Pubid::Identifier contract (format_registry, render,
    # to_urn, exclude, hash, eql?) while allowing CIE-specific attributes
    # such as +style+ ("legacy" vs "current" date separator).
    class Identifier < ::Pubid::Identifier
      attribute :style, :string # "legacy" or "current"

      def self.parse(input)
        parsed = Parser.parse(input)
        builder = Builder.new
        builder.build(parsed, original_string: input)
      end
    end
  end
end
