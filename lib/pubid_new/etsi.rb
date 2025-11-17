require "parslet"
require_relative "etsi/parser"
require_relative "etsi/scheme"
require_relative "etsi/builder"

module PubidNew
  module Etsi
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