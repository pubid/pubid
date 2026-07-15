# frozen_string_literal: true

module Pubid
  # XSF (XMPP Standards Foundation) flavor. Its documents are XEPs — XMPP
  # Extension Protocols — printed as "XEP NNNN" with a 4-digit zero-padded
  # number (e.g. "XEP 0001"). The simplest full flavor: a single identifier
  # type, one string attribute.
  module Xsf
    extend Pubid::PrefixesSupport

    # Sole leading token an XSF identifier can start with (see the parser's
    # `str("XEP")`). "XSF" is the publisher name but never appears in a printed
    # identifier, so it is not a prefix.
    PREFIXES = ["XEP"].freeze

    autoload :Builder, "#{__dir__}/xsf/builder"
    autoload :Identifier, "#{__dir__}/xsf/identifier"
    autoload :Identifiers, "#{__dir__}/xsf/identifiers"
    autoload :Parser, "#{__dir__}/xsf/parser"
    autoload :Renderer, "#{__dir__}/xsf/renderer"
    autoload :UrnGenerator, "#{__dir__}/xsf/urn_generator"
    autoload :UrnParser, "#{__dir__}/xsf/urn_parser"

    # Parse an XSF identifier string
    def self.parse(identifier)
      if identifier.length > Pubid::MAX_INPUT_LENGTH
        raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
      end

      Identifier.parse(identifier)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Xsf::Renderer)

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

# Register XSF flavor with the registry
Pubid::Registry.register(:xsf, Pubid::Xsf)
