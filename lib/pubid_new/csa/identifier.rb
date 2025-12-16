# frozen_string_literal: true

require_relative "parser"
require_relative "builder"
require_relative "single_identifier"

module PubidNew
  module Csa
    class Identifier
      def self.parse(input)
        # Filter out comments
        return nil if input.start_with?("#")

        # Filter out non-standards
        return nil if input.match?(/^CSA (Communities|Group|Learning|OnDemand|Update)/)

        # Normalize CAN/CSA- to CSA
        normalized = input.gsub(/^CAN\/CSA-/, "CSA ")

        tree = Parser.new.parse(normalized)
        Builder.new.build(tree)
      rescue Parslet::ParseFailed => e
        raise e
      end
    end
  end
end