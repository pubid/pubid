# frozen_string_literal: true

module Pubid
  module Api
    # Common base class for all API identifiers. SingleIdentifier and the
    # concrete Identifiers::* types descend from it, so every API identifier is
    # `is_a?(Pubid::Api::Identifier)` natively and gets the shared polymorphic
    # `from_hash` (no facade needed).
    class Identifier < ::Pubid::Identifier
      # `number`/`part`/`subpart` are declared here rather than inherited as a
      # Components::Code: API stores a bare string in every one of them.
      # Declaring on this class is safe because its body lives in this one file
      # and is never reopened, so every subclass body opens after it has run
      # (lutaml deep-dups the parent attribute table at class-definition time).
      # `code` keeps its Components::Code type on SingleIdentifier - it is not
      # one of the three attributes the shared base declares.
      attribute :number, :string
      attribute :part, :string
      attribute :subpart, :string

      def self.parse(input)
        unless input.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if input.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        # There used to be a `return nil if input.start_with?("#")` here, to
        # skip the comment lines of a fixture file. A comment is not an
        # identifier, so it must be rejected like any other unparseable string:
        # this was the one public parse in the gem that could return nil, which
        # a caller reading `id.to_s` sees as a NoMethodError far from the cause.
        # Both API fixture loaders already drop `#` lines themselves.
        tree = Parser.new.parse(input)
        Builder.new.build(tree)
      end
    end
  end
end
