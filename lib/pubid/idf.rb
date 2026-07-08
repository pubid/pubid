# frozen_string_literal: true

module Pubid
  module Idf
    extend Pubid::PrefixesSupport

    # Sole IDF publisher token (see the parser's `prefix_sole_publisher` rule).
    PREFIXES = ["IDF"].freeze

    autoload :Builder, "#{__dir__}/idf/builder"
    autoload :Identifier, "#{__dir__}/idf/identifier"
    autoload :Identifiers, "#{__dir__}/idf/identifiers"
    autoload :Parser, "#{__dir__}/idf/parser"
    autoload :Renderer, "#{__dir__}/idf/renderer"
    autoload :SingleIdentifier, "#{__dir__}/idf/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/idf/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/idf/urn_generator"
    autoload :UrnParser, "#{__dir__}/idf/urn_parser"

    def self.parse(identifier)
      if identifier.length > Pubid::MAX_INPUT_LENGTH
        raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
      end

      parser = Parser.new
      builder = Builder.new

      parsed = parser.parse(identifier)
      builder.build(parsed)
    end

    # Build an IDF identifier from a parse-tree hash (used by ISO joint-identifier
    # parsing). This is the public seam: callers should never reach into
    # `Idf::Builder` directly.
    # @param hash [Hash] parse tree for the joint identifier
    # @return [Pubid::Idf::Identifier]
    def self.build_from_parse(hash)
      Builder.new.build(hash)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Idf::Renderer)

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

# Register Uidf flavor with the registry
Pubid::Registry.register(:idf, Pubid::Idf)
