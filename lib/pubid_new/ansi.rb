# frozen_string_literal: true

module PubidNew
  module Ansi
    # Parse an ANSI identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifier] the parsed identifier
    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new(Scheme)
      
      parsed = parser.parse(identifier)
      builder.build(parsed)
    end
  end
end

require_relative "ansi/identifier"
require_relative "ansi/single_identifier"
require_relative "ansi/identifiers/american_national_standard"
require_relative "ansi/scheme"
require_relative "ansi/parser"
require_relative "ansi/builder"