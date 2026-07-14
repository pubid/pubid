# frozen_string_literal: true

module Pubid
  module Gost
    extend Pubid::PrefixesSupport

    # Leading identifier tokens that a GOST document id can start with.
    # Latin "GOST" and Cyrillic "ГОСТ" are both official; "R" (Russian
    # national, e.g. "GOST R 34.12-2015") routes to this flavor too.
    PREFIXES = ["GOST", "ГОСТ"].freeze

    autoload :Builder,      "#{__dir__}/gost/builder"
    autoload :Identifier,   "#{__dir__}/gost/identifier"
    autoload :Identifiers,  "#{__dir__}/gost/identifiers"
    autoload :Parser,       "#{__dir__}/gost/parser"
    autoload :Renderer,     "#{__dir__}/gost/renderer"
    autoload :UrnGenerator, "#{__dir__}/gost/urn_generator"
    autoload :UrnParser,    "#{__dir__}/gost/urn_parser"

    # Parse a GOST identifier string into an identifier object.
    # @param identifier [String]
    # @return [Pubid::Gost::Identifier]
    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    # Per-flavor format registry: inherits global formats, overrides :human.
    Identifiers::Base.format_registry = FormatRegistry.new(parent: ::Pubid::Identifier.format_registry)
    Identifiers::Base.format_registry.register(:human, renderer: Gost::Renderer)

    # Auto-discover identifier types from the Identifiers namespace.
    # @return [Array<Class>]
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c < Pubid::Identifier }
        .reject { |c| c == Identifiers::Base }
    end

    # Lookup: type key → identifier class
    # @param code [String, Symbol]
    # @return [Class, nil]
    def self.locate_type(code)
      identifier_types.find { |t| t.type[:key].to_s == code.to_s }
    end
  end
end

Pubid::Registry.register(:gost, Pubid::Gost)
