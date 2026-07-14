# frozen_string_literal: true

module Pubid
  module Bipm
    extend Pubid::PrefixesSupport

    # Leading tokens a printed BIPM identifier can start with: the 13 committee
    # acronyms, "Metrologia" (journal), and "BIPM" (the SI Brochure). JCGM is
    # deliberately excluded — it is owned by the separate Pubid::Jcgm flavor,
    # so BIPM never emits pubid:jcgm:* rows. French full-name forms that lead
    # with a type word ("Recommandation 1 du CCL …") are omitted per the
    # "exclude ambiguous tokens" policy.
    PREFIXES = %w[
      BIPM Metrologia
      CIPM CGPM JCRB CCTF CCQM CCT CCL CCAUV CCU CCM CCEM CCPR CCRI
    ].freeze

    autoload :Builder, "#{__dir__}/bipm/builder"
    autoload :Identifier, "#{__dir__}/bipm/identifier"
    autoload :Identifiers, "#{__dir__}/bipm/identifiers"
    autoload :Parser, "#{__dir__}/bipm/parser"
    autoload :Renderer, "#{__dir__}/bipm/renderer"
    autoload :UrnGenerator, "#{__dir__}/bipm/urn_generator"
    autoload :UrnParser, "#{__dir__}/bipm/urn_parser"

    # Parse a BIPM identifier string into an identifier object.
    # @param identifier [String] the printed identifier
    # @return [Identifier] the parsed identifier
    def self.parse(identifier)
      if identifier.length > Pubid::MAX_INPUT_LENGTH
        raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
      end

      Identifier.parse(identifier)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Bipm::Renderer)

    # Auto-discover all identifier types from the Identifiers namespace
    # @return [Array<Class>] identifier classes that define a self.type Hash
    def self.identifier_types
      @identifier_types ||= Identifiers.constants.filter_map do |const|
        klass = Identifiers.const_get(const)
        klass if klass.is_a?(Class) &&
          klass.singleton_methods(false).include?(:type) &&
          klass.type.is_a?(Hash)
      rescue NameError
        nil
      end
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
      all_typed_stages.find do |s|
        s.abbr.any? { |a| a.to_s.upcase == abbr_str }
      end
    end
  end
end

# Register BIPM flavor with the registry
Pubid::Registry.register(:bipm, Pubid::Bipm)
