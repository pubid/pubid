# frozen_string_literal: true

module Pubid
  # 3GPP (3rd Generation Partnership Project) flavor.
  #
  # The Ruby constant is `Pubid::Tgpp` because a constant may not begin with a
  # digit, but the external contract stays "3gpp": the registry key is "3gpp",
  # the polymorphic `_type` is `pubid:3gpp:…`, and URNs use the `urn:3gpp:`
  # namespace. Only the on-disk file names (lib/pubid/tgpp/…) follow the module.
  module Tgpp
    extend Pubid::PrefixesSupport

    # Sole routing token. 3GPP references are printed as "3GPP TS 23.207:…";
    # the bare document types (TR/TS) are ambiguous (JIS uses them too) and are
    # excluded. The parser still accepts an optional leading "3GPP ".
    PREFIXES = ["3GPP"].freeze

    autoload :Builder, "#{__dir__}/tgpp/builder"
    autoload :Identifier, "#{__dir__}/tgpp/identifier"
    autoload :Identifiers, "#{__dir__}/tgpp/identifiers"
    autoload :Parser, "#{__dir__}/tgpp/parser"
    autoload :Renderer, "#{__dir__}/tgpp/renderer"
    autoload :UrnGenerator, "#{__dir__}/tgpp/urn_generator"
    autoload :UrnParser, "#{__dir__}/tgpp/urn_parser"

    # Parse a 3GPP identifier string
    def self.parse(identifier)
      if identifier.length > Pubid::MAX_INPUT_LENGTH
        raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
      end

      Identifier.parse(identifier)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Tgpp::Renderer)

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

# Register 3GPP flavor with the registry (external key stays "3gpp").
Pubid::Registry.register(:"3gpp", Pubid::Tgpp)
