# frozen_string_literal: true

module Pubid
  module Api
    # Common base class for all API identifiers. SingleIdentifier and the
    # concrete Identifiers::* types descend from it, so every API identifier is
    # `is_a?(Pubid::Api::Identifier)` natively and gets the shared polymorphic
    # `from_hash` (no facade needed).
    class Identifier < ::Pubid::Identifier
      def self.parse(input)
        # Filter out comments
        return nil if input.start_with?("#")

        tree = Parser.new.parse(input)
        Builder.new.build(tree)
      rescue Parslet::ParseFailed => e
        raise e
      end
    end
  end
end
