# frozen_string_literal: true

module Pubid
  module W3c
    extend Pubid::PrefixesSupport

    # Sole W3C publisher token (see the parser's `prefix` rule). Document-type
    # tokens (WD/NOTE/REC/…) follow the "W3C " prefix and are excluded.
    PREFIXES = ["W3C"].freeze

    autoload :Builder, "#{__dir__}/w3c/builder"
    autoload :Identifier, "#{__dir__}/w3c/identifier"
    autoload :Identifiers, "#{__dir__}/w3c/identifiers"
    autoload :Parser, "#{__dir__}/w3c/parser"
    autoload :Renderer, "#{__dir__}/w3c/renderer"
    autoload :UrnGenerator, "#{__dir__}/w3c/urn_generator"
    autoload :UrnParser, "#{__dir__}/w3c/urn_parser"

    # Parse a W3C identifier string
    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: W3c::Renderer)

    # Auto-discover all identifier types from the Identifiers namespace
    # @return [Array<Class>] identifier classes that define a self.type Hash
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c.singleton_methods(false).include?(:type) }
        .select { |c| c.type.is_a?(Hash) }
    end

    # Build typed stage index from identifier types
    # @return [Array<Pubid::Components::TypedStage>] all typed stages
    def self.all_typed_stages
      @all_typed_stages ||= identifier_types.flat_map do |klass|
        if klass.const_defined?(:TYPED_STAGES)
          klass.const_get(:TYPED_STAGES)
        else
          []
        end
      end
    end

    # Lookup: type code -> identifier class
    # @param code [String, Symbol] the type key to find
    # @return [Class, nil] the matching identifier class
    def self.locate_type(code)
      identifier_types.find { |t| t.type[:key].to_s == code.to_s }
    end

    # Lookup: abbreviation -> typed stage
    # @param abbr [String, Symbol] the abbreviation to find
    # @return [Pubid::Components::TypedStage, nil] the matching typed stage
    def self.locate_stage(abbr)
      abbr_str = abbr.to_s.upcase
      all_typed_stages.find { |s| s.abbr.any? { |a| a.to_s.upcase == abbr_str } }
    end
  end
end

# Register W3C flavor with the registry
Pubid::Registry.register(:w3c, Pubid::W3c)
