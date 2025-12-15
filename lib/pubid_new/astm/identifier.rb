# frozen_string_literal: true

module PubidNew
  module Astm
    class Identifier < PubidNew::Identifier
      def self.parse(str)
        parser = Parser.new
        builder = Builder.new

        parsed = parser.parse(str)
        builder.build(parsed)
      end
    end
  end
end