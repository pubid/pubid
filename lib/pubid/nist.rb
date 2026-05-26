# frozen_string_literal: true

module Pubid
  module Nist
    autoload :Builder, "#{__dir__}/nist/builder"
    autoload :Components, "#{__dir__}/nist/components"
    autoload :Configuration, "#{__dir__}/nist/configuration"
    autoload :Identifier, "#{__dir__}/nist/identifier"
    autoload :Identifiers, "#{__dir__}/nist/identifiers"
    autoload :Parser, "#{__dir__}/nist/parser"
    autoload :Scheme, "#{__dir__}/nist/scheme"
    autoload :SupplementIdentifier, "#{__dir__}/nist/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/nist/urn_generator"

    # Parse a NIST identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifiers::Base] the parsed identifier
    def self.parse(identifier)
      # Use the Parser class's preprocessing method
      # Note: We call the class method directly to ensure preprocessing is applied
      parsed = Parser.class_parse_with_preprocessing(identifier)

      # Use Scheme and Builder for clean architecture
      # ONE CLASS PER SERIES TYPE (like ISO)
      builder = Builder.new(Scheme)
      builder.build(parsed)
    end

    # Get the configuration instance
    # @return [Configuration] the configuration instance
    def self.configuration
      @configuration ||= Configuration.new
    end
  end
end

Pubid::Registry.register(:nist, Pubid::Nist)
