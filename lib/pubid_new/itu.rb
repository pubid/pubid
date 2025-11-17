require_relative "itu/parser"
require_relative "itu/scheme"
require_relative "itu/model"
require_relative "itu/builder"

module PubidNew
  module Itu
    def self.parse(identifier_string)
      parser = Parser.new
      parsed = parser.parse(identifier_string)
      builder = Builder.new(Scheme)
      builder.build(parsed)
    end
  end
end