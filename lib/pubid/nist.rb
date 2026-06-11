# frozen_string_literal: true

module Pubid
  module Nist
    autoload :Builder, "#{__dir__}/nist/builder"
    autoload :Caster, "#{__dir__}/nist/caster"
    autoload :CircularSupplementBuilder, "#{__dir__}/nist/circular_supplement_builder"
    autoload :Components, "#{__dir__}/nist/components"
    autoload :Configuration, "#{__dir__}/nist/configuration"
    autoload :Identifier, "#{__dir__}/nist/identifier"
    autoload :Identifiers, "#{__dir__}/nist/identifiers"
    autoload :Parser, "#{__dir__}/nist/parser"
    autoload :ParserOutputNormalizer, "#{__dir__}/nist/parser_output_normalizer"
    autoload :Renderer, "#{__dir__}/nist/renderer"
    autoload :Router, "#{__dir__}/nist/router"
    autoload :Scheme, "#{__dir__}/nist/scheme"
    autoload :SupplementIdentifier, "#{__dir__}/nist/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/nist/urn_generator"

    # Parse a NIST identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifiers::Base] the parsed identifier
    def self.parse(identifier)
      # Use the Parser class's preprocessing method
      # Note: We call the class method directly to ensure preprocessing is applied
      parsed = Parser.class_parse_with_preprocessing(identifier)

      # Use Scheme and Builder for clean architecture
      # ONE CLASS PER SERIES TYPE (like ISO)
      builder = Builder.new(Scheme)
      builder.build(parsed)
    end

    # Get the configuration instance
    # @return [Configuration] the configuration instance
    def self.configuration
      @configuration ||= Configuration.new
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifiers::Base.format_registry = FormatRegistry.new(parent: ::Pubid::Identifier.format_registry)
    Identifiers::Base.format_registry.register(:human, renderer: Nist::Renderer)

    # Auto-discover all identifier types via Scheme registry
    # NIST identifier classes use typed_stages (not self.type Hash),
    # so we delegate to the Scheme's explicit list.
    # @return [Array<Class>] identifier classes registered in the Scheme
    def self.identifier_types
      @identifier_types ||= Scheme.identifiers
    end

    # Build typed stage index from Scheme
    # @return [Array<Pubid::Components::TypedStage>] all typed stages
    def self.all_typed_stages
      @all_typed_stages ||= Scheme.typed_stages
    end

    # Lookup: type code -> identifier class
    # Delegates to Scheme for NIST-specific lookup (uses typed_stages.type_code)
    # @param code [String, Symbol] the type code to find
    # @return [Class, nil] the matching identifier class
    def self.locate_type(code)
      begin
        Scheme.locate_identifier_klass_by_type_code(code)
      rescue ArgumentError
        nil
      end
    end

    # Lookup: abbreviation -> typed stage
    # Delegates to Scheme for NIST-specific lookup
    # @param abbr [String, Symbol] the abbreviation to find
    # @return [Pubid::Components::TypedStage, nil] the matching typed stage
    def self.locate_stage(abbr)
      abbr_str = abbr.to_s.upcase
      all_typed_stages.find { |s| s.abbr.any? { |a| a.to_s.upcase == abbr_str } }
    end
  end
end

Pubid::Registry.register(:nist, Pubid::Nist)
