# frozen_string_literal: true

module Pubid
  module Iala
    autoload :Builder,      "#{__dir__}/iala/builder"
    autoload :Identifier,   "#{__dir__}/iala/identifier"
    autoload :Identifiers,  "#{__dir__}/iala/identifiers"
    autoload :Parser,       "#{__dir__}/iala/parser"
    autoload :Renderer,     "#{__dir__}/iala/renderer"
    autoload :UrnGenerator, "#{__dir__}/iala/urn_generator"
    autoload :UrnParser,    "#{__dir__}/iala/urn_parser"

    # Parse an IALA identifier string into an identifier object.
    # @param identifier [String] The IALA identifier string to parse
    # @return [Pubid::Iala::Identifier]
    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifiers::Base.format_registry = FormatRegistry.new(parent: ::Pubid::Identifier.format_registry)
    Identifiers::Base.format_registry.register(:human, renderer: Iala::Renderer)

    # Auto-discover all identifier types from the Identifiers namespace.
    # @return [Array<Class>] identifier classes (Pubid::Identifier subclasses)
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c < Pubid::Identifier }
        .reject { |c| c == Identifiers::Base }
    end

    # Build typed stage index from identifier types
    # @return [Array<Pubid::Components::TypedStage>]
    def self.all_typed_stages
      @all_typed_stages ||= identifier_types.flat_map do |klass|
        klass.const_defined?(:TYPED_STAGES) ? klass.const_get(:TYPED_STAGES) : []
      end
    end

    # Lookup: type code -> identifier class
    # @param code [String, Symbol]
    # @return [Class, nil]
    def self.locate_type(code)
      identifier_types.find { |t| t.type[:key].to_s == code.to_s }
    end

    # Lookup: abbreviation -> typed stage
    # @param abbr [String, Symbol]
    # @return [Pubid::Components::TypedStage, nil]
    def self.locate_stage(abbr)
      abbr_str = abbr.to_s.upcase
      all_typed_stages.find { |s| s.abbr.any? { |a| a.to_s.upcase == abbr_str } }
    end

    # Look up an identifier class by its IALA type letter (S, R, G, M, C, X, P).
    # @param letter [String]
    # @return [Class<Identifiers::Base>]
    def self.identifier_klass_for_type_letter(letter)
      @by_letter ||= identifier_types.to_h { |klass| [klass.type[:short], klass] }
      @by_letter.fetch(letter.to_s.upcase)
    end
  end
end

Pubid::Registry.register(:iala, Pubid::Iala)
