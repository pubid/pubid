# frozen_string_literal: true

module Pubid
  module Adobe
    extend Pubid::PrefixesSupport

    # Leading identifier prefix tokens that an Adobe document id can start
    # with. Tech notes appear as both `Adobe Technical Note #<n>` and the
    # short alias `ATN<n>` in citations; both must route to this flavor.
    # Named publications start with `Adobe` (e.g. `Adobe Glyph List`,
    # `Adobe-Japan1-7`).
    PREFIXES = ["Adobe", "ATN"].freeze

    autoload :Builder,      "#{__dir__}/adobe/builder"
    autoload :Identifier,   "#{__dir__}/adobe/identifier"
    autoload :Identifiers,  "#{__dir__}/adobe/identifiers"
    autoload :Parser,       "#{__dir__}/adobe/parser"
    autoload :Renderer,     "#{__dir__}/adobe/renderer"
    autoload :UrnGenerator, "#{__dir__}/adobe/urn_generator"
    autoload :UrnParser,    "#{__dir__}/adobe/urn_parser"

    # Parse an Adobe identifier string into an identifier object.
    # @param identifier [String]
    # @return [Pubid::Adobe::Identifier]
    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    # with the Adobe-specific renderer.
    Identifier.format_registry = FormatRegistry.new(parent: ::Pubid::Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Adobe::Renderer)

    # Auto-discover identifier types from the Identifiers namespace.
    # @return [Array<Class>]
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c < Pubid::Identifier }
        .reject { |c| c == Identifier }
    end

    # Lookup: type key → identifier class
    # @param code [String, Symbol]
    # @return [Class, nil]
    def self.locate_type(code)
      identifier_types.find { |t| t.type[:key].to_s == code.to_s }
    end

    # Lookup: type short letter (e.g. "ATN") → identifier class
    # @param short [String]
    # @return [Class<Identifier>]
    def self.identifier_klass_for_short(short)
      @by_short ||= identifier_types.to_h { |klass| [klass.type[:short].to_s, klass] }
      @by_short.fetch(short.to_s)
    end
  end
end

Pubid::Registry.register(:adobe, Pubid::Adobe)
