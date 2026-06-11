# frozen_string_literal: true

module Pubid
  module Api
    class Identifier
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
