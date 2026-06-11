# frozen_string_literal: true

module Pubid
  module Oiml
    autoload :Builder, "#{__dir__}/oiml/builder"
    autoload :Components, "#{__dir__}/oiml/components"
    autoload :Identifier, "#{__dir__}/oiml/identifier"
    autoload :Identifiers, "#{__dir__}/oiml/identifiers"
    autoload :Parser, "#{__dir__}/oiml/parser"
    autoload :Renderer, "#{__dir__}/oiml/renderer"
    autoload :Scheme, "#{__dir__}/oiml/scheme"
    autoload :SingleIdentifier, "#{__dir__}/oiml/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/oiml/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/oiml/urn_generator"

    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new

      parsed = parser.parse(identifier)
      builder.build(parsed)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Oiml::Renderer)

    # Auto-discover all identifier types from the Identifiers namespace
    # @return [Array<Class>] identifier classes that define a self.type Hash
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c.respond_to?(:type) }
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

# Register Uoiml flavor with the registry
Pubid::Registry.register(:oiml, Pubid::Oiml)
