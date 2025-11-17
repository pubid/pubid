require "parslet"
require_relative "plateau/parser"
require_relative "plateau/scheme"
require_relative "plateau/builder"

module PubidNew
  module Plateau
    class << self
      def parse(input)
        parser = Parser.new
        parsed = parser.parse(input)
        builder = Builder.new(Scheme)
        builder.build(parsed)
      end
    end
  end
end