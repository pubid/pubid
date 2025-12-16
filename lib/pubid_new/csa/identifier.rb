# frozen_string_literal: true

require_relative "parser"
require_relative "builder"
require_relative "single_identifier"

module PubidNew
  module Csa
    class Identifier
      def self.parse(input)
        # Filter out non-standards
        return nil if input.match?(/^CSA (Communities|Group|Learning|OnDemand|Update)/)

        tree = Parser.new.parse(input)
        Builder.new.build(tree)
      rescue Parslet::ParseFailed => e
        raise e
      end
    end
  end
end