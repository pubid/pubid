# frozen_string_literal: true

module Pubid
  module Ansi
    extend Pubid::PrefixesSupport

    # ANSI publisher token; ANSI/ASHRAE and ANSI/AMCA joint forms come from
    # Pubid::JOINT_PREFIXES. Parser::ORGANIZATIONS are co-publishers, not
    # leading ANSI tokens, so they are excluded.
    PREFIXES = ["ANSI"].freeze

    autoload :Builder, "#{__dir__}/ansi/builder"
    autoload :Identifier, "#{__dir__}/ansi/identifier"
    autoload :Identifiers, "#{__dir__}/ansi/identifiers"
    autoload :Parser, "#{__dir__}/ansi/parser"
    autoload :Renderer, "#{__dir__}/ansi/renderer"
    autoload :SingleIdentifier, "#{__dir__}/ansi/single_identifier"
    autoload :UrnGenerator, "#{__dir__}/ansi/urn_generator"
    autoload :UrnParser, "#{__dir__}/ansi/urn_parser"

    # Parse an ANSI identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifier] the parsed identifier
    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new

      parsed = parser.parse(identifier)
      builder.build(parsed)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Ansi::Renderer)

    # Auto-discover all identifier types from the Identifiers namespace
    # @return [Array<Class>] identifier classes that define a self.type Hash
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c.singleton_methods(false).include?(:type) }
        .select { |c| c.type.is_a?(Hash) }
    end

    # ANSI does not define typed stages; typed_stage lookup is not used by
    # the builder. Provided here for API consistency with other flavors.
    # @return [Array] always empty for ANSI
    def self.all_typed_stages
      []
    end

    # Lookup: type code -> identifier class
    # @param code [String, Symbol] the type key to find
    # @return [Class, nil] the matching identifier class
    def self.locate_type(code)
      identifier_types.find { |t| t.type[:key].to_s == code.to_s }
    end

    # Lookup: abbreviation -> typed stage
    # @param _abbr [String, Symbol] unused; ANSI has no typed stages
    # @return [nil] always nil for ANSI
    def self.locate_stage(_abbr)
      nil
    end
  end
end

# Register ANSI flavor with the registry
Pubid::Registry.register(:ansi, Pubid::Ansi)
