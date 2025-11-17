# frozen_string_literal: true

require_relative "ieee/parser"
require_relative "ieee/scheme"
require_relative "ieee/builder"

module PubidNew
  module Ieee
    # Parse an IEEE identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Scheme] the parsed identifier scheme
    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new(Scheme)
      
      parsed = parser.parse(identifier)
      builder.build(parsed)
    end
  end
end