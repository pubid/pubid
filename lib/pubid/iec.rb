# frozen_string_literal: true

module Pubid
  module Iec
  end
end

# Namespace files (autoload their children)
require_relative "iec/components"
require_relative "iec/identifiers"

# Autoload top-level IEC constants
module Pubid
  module Iec
    autoload :Identifier, "#{__dir__}/iec/identifier"
    autoload :SingleIdentifier, "#{__dir__}/iec/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/iec/supplement_identifier"
    autoload :Scheme, "#{__dir__}/iec/scheme"
    autoload :Parser, "#{__dir__}/iec/parser"
    autoload :Builder, "#{__dir__}/iec/builder"
    autoload :UrnParser, "#{__dir__}/iec/urn_parser"
    autoload :UrnGenerator, "#{__dir__}/iec/urn_generator"
    autoload :RenderingStyle, "#{__dir__}/iec/rendering_style"
    autoload :Renderer, "#{__dir__}/iec/renderer"

    # Primary document types (not supplements)
    IDENTIFIER_TYPES = [
      Identifiers::InternationalStandard,
      Identifiers::TechnicalReport,
      Identifiers::TechnicalSpecification,
      Identifiers::PubliclyAvailableSpecification,
      Identifiers::Guide,
      Identifiers::TestReportForm,
      Identifiers::InterpretationSheet,
      Identifiers::SystemsReferenceDocument,
      Identifiers::WorkingDocument,
    ].freeze

    # Supplement types (can appear with / notation)
    SUPPLEMENT_IDENTIFIER_TYPES = [
      Identifiers::Amendment,
      Identifiers::Corrigendum,
      Identifiers::InterpretationSheet, # ISH can act as supplement (/ISH1:1996)
      Identifiers::FragmentIdentifier,  # FRAG wraps amendments/corrigenda
    ].freeze

    # Create the Scheme registry with all identifier types
    Scheme = Pubid::Scheme.new(
      identifiers: IDENTIFIER_TYPES,
      supplement_identifiers: SUPPLEMENT_IDENTIFIER_TYPES,
    )

    # Main entry point for IEC identifiers
    def self.parse(identifier_string)
      parsed = Parser.new.parse(identifier_string)
      Builder.new(Scheme).build(parsed)
    end

    # Parse an IEC URN string
    # @param urn [String] the URN string to parse
    # @return [Identifier] the parsed identifier
    # @raise [Errors::ParseError] if URN is invalid
    def self.parse_urn(urn)
      UrnParser.parse(urn)
    end
    # Per-flavor format registry: inherits global formats, overrides :human
    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Iec::Renderer)

    # Auto-discover all identifier types from the Identifiers namespace
    # @return [Array<Class>] identifier classes that define a self.type Hash
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c.respond_to?(:type) }
        .select { |c| begin; c.type.is_a?(Hash); rescue NotImplementedError; false; end }
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

Pubid::Registry.register(:iec, Pubid::Iec)
