# frozen_string_literal: true

module Pubid
  module Iana
    extend Pubid::PrefixesSupport

    # Sole IANA publisher token (see the parser's optional `IANA ` prefix).
    # IANA entries are protocol registries whose printed form always leads with
    # the "IANA" token; routing relies on it since the raw slug carries no
    # publisher.
    PREFIXES = ["IANA"].freeze

    autoload :Builder, "#{__dir__}/iana/builder"
    autoload :Identifier, "#{__dir__}/iana/identifier"
    autoload :Identifiers, "#{__dir__}/iana/identifiers"
    autoload :Parser, "#{__dir__}/iana/parser"
    autoload :Renderer, "#{__dir__}/iana/renderer"
    autoload :UrnGenerator, "#{__dir__}/iana/urn_generator"
    autoload :UrnParser, "#{__dir__}/iana/urn_parser"

    # Parse an IANA identifier string
    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Iana::Renderer)

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

# Register IANA flavor with the registry
Pubid::Registry.register(:iana, Pubid::Iana)
