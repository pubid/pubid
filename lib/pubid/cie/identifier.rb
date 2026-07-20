# frozen_string_literal: true

module Pubid
  module Cie
    # Base Identifier class for CIE.
    #
    # Inherits the shared Pubid::Identifier contract (format_registry, render,
    # to_urn, exclude, hash, eql?) while allowing CIE-specific attributes.
    #
    # +style+ is the sole number<->year separator field (there is no separate
    # date_separator): "current" -> ":", "legacy" -> "-", "slash" -> "/".
    # It defaults to "current" (the dominant value), so canonicalize_hash drops
    # it from the majority of rows and from_hash restores it.
    class Identifier < ::Pubid::Identifier
      attribute :style, :string, default: -> { "current" }

      def self.parse(input)
        if input.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Parser.parse(input)
        builder = Builder.new
        builder.build(parsed, original_string: input)
      end
    end
  end
end
