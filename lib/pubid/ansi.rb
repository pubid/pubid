# frozen_string_literal: true

module Pubid
  module Ansi
    autoload :Builder, "#{__dir__}/ansi/builder"
    autoload :Identifier, "#{__dir__}/ansi/identifier"
    autoload :Identifiers, "#{__dir__}/ansi/identifiers/standard"
    autoload :Parser, "#{__dir__}/ansi/parser"
    autoload :Renderer, "#{__dir__}/ansi/renderer"
    autoload :Scheme, "#{__dir__}/ansi/scheme"
    autoload :SingleIdentifier, "#{__dir__}/ansi/single_identifier"
    autoload :UrnGenerator, "#{__dir__}/ansi/urn_generator"

    # Parse an ANSI identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifier] the parsed identifier
    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new(Scheme)

      parsed = parser.parse(identifier)
      builder.build(parsed)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Ansi::Renderer)
  end
end

# Register ANSI flavor with the registry
Pubid::Registry.register(:ansi, Pubid::Ansi)
