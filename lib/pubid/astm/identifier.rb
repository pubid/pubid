# frozen_string_literal: true

module Pubid
  module Astm
    class Identifier < Pubid::Identifier
      def self.parse(str)
        parser = Parser.new
        builder = Builder.new

        parsed = parser.parse(str)
        builder.build(parsed)
      end
    end
  end
end
