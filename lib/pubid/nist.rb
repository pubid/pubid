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
    autoload :SupplementIdentifier, "#{__dir__}/nist/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/nist/urn_generator"
    autoload :UrnParser, "#{__dir__}/nist/urn_parser"

    # Explicit registry of NIST identifier classes.
    #
    # NIST identifier classes use `typed_stages` (not the `self.type` Hash
    # pattern used by CEN/JCGM/ANSI), so they cannot be auto-discovered.
    # Identifiers::Base is the fallback for unmapped series (e.g. AMS, VTS)
    # and must be excluded from typed-stage aggregation.
    IDENTIFIER_TYPES = [
      Identifiers::SpecialPublication,
      Identifiers::FederalInformationProcessingStandards,
      Identifiers::InteragencyReport,
      Identifiers::Handbook,
      Identifiers::TechnicalNote,
      Identifiers::Circular,
      Identifiers::CircularSupplement,
      Identifiers::CrplReport,
      Identifiers::Report,
      Identifiers::Monograph,
      Identifiers::MiscellaneousPublication,
      Identifiers::GrantContractorReport,
      Identifiers::Ncstar,
      Identifiers::Owmwp,
      Identifiers::Nsrds,
      Identifiers::LetterCircular,
      Identifiers::CommercialStandard,
      Identifiers::CommercialStandardEmergency,
      Identifiers::CommercialStandardsMonthly,
      Identifiers::Base, # Fallback for unmapped series
    ].freeze

    # Parse a NIST identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifiers::Base] the parsed identifier
    def self.parse(identifier)
      # Use the Parser class's preprocessing method
      # Note: We call the class method directly to ensure preprocessing is applied
      parsed = Parser.class_parse_with_preprocessing(identifier)

      # Builder is stateless — lookups go through this module (Pubid::Nist)
      builder = Builder.new
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

    # All identifier classes for external consumption (export, website).
    # Identifiers::Base is the fallback for unmapped series and is excluded
    # from external type listings.
    # @return [Array<Class>] identifier classes
    def self.identifier_types
      IDENTIFIER_TYPES.reject { |klass| klass == Identifiers::Base }
    end

    # Aggregate TYPED_STAGES from all identifier classes.
    # Identifiers::Base is excluded because it has no typed stages and acts
    # as the fallback for unmapped series.
    # @return [Array<Pubid::Components::TypedStage>] all typed stages
    def self.all_typed_stages
      @all_typed_stages ||= identifier_types
        .reject { |klass| klass == Identifiers::Base }
        .flat_map(&:typed_stages)
        .freeze
    end

    # Lookup: type code -> identifier class.
    # Identifiers::Base is excluded so it never gets selected by type code.
    # @param code [String, Symbol] the type code to find
    # @return [Class, nil] the matching identifier class, or nil
    def self.locate_type(code)
      type_str = code.to_s
      identifier_types
        .reject { |klass| klass == Identifiers::Base }
        .find { |klass| klass.typed_stages.any? { |ts| ts.type_code.to_s == type_str } }
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

Pubid::Registry.register(:nist, Pubid::Nist)
