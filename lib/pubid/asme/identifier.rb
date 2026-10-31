# frozen_string_literal: true

module Pubid
  module Asme
    class Identifier < Pubid::Identifier
      def self.parse(str)
        unless str.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if str.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        builder = Builder.new

        parsed = Pubid::Parg::Model.bound(:asme, str)
        builder.build(parsed)
      end
    end
  end
end
