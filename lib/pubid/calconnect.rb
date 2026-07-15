# frozen_string_literal: true

module Pubid
  # CalConnect (The Calendaring and Scheduling Consortium) flavor.
  #
  # Parses/renders the "CC …" numbering, e.g. "CC 18011:2018",
  # "CC/DIR 10006:2019", "CC/Adv 0707.1:2007". Modeled on Pubid::Jis: a single
  # flat identifier type (Identifiers::Standard) with no supplement layer.
  module Calconnect
    extend Pubid::PrefixesSupport

    # Sole CalConnect publisher/leading token. Series letters (A, WD, R, S, CD,
    # DIR, Adv, FDS) follow "CC/" and never lead a reference, so they are
    # excluded per the PrefixesSupport inclusion policy.
    PREFIXES = ["CC"].freeze

    autoload :Builder, "#{__dir__}/calconnect/builder"
    autoload :Identifier, "#{__dir__}/calconnect/identifier"
    autoload :Identifiers, "#{__dir__}/calconnect/identifiers"
    autoload :Parser, "#{__dir__}/calconnect/parser"
    autoload :Renderer, "#{__dir__}/calconnect/renderer"
    autoload :UrnGenerator, "#{__dir__}/calconnect/urn_generator"
    autoload :UrnParser, "#{__dir__}/calconnect/urn_parser"

    # Parse a CalConnect identifier string
    def self.parse(identifier)
      if identifier.length > Pubid::MAX_INPUT_LENGTH
        raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
      end

      Identifier.parse(identifier)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Calconnect::Renderer)

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

# Register CalConnect flavor with the registry
Pubid::Registry.register(:calconnect, Pubid::Calconnect)
