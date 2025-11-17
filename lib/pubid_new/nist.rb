# frozen_string_literal: true

require_relative "nist/configuration"
require_relative "nist/parser"
require_relative "nist/scheme"
require_relative "nist/builder"

module PubidNew
  module Nist
    # Parse a NIST identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Scheme] the parsed identifier scheme
    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new(Scheme)
      
      parsed = parser.parse(identifier)
      builder.build(parsed)
    end

    # Get the configuration instance
    # @return [Configuration] the configuration instance
    def self.configuration
      @configuration ||= Configuration.new
    end
  end
end