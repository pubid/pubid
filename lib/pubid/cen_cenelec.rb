# frozen_string_literal: true

module Pubid
  module CenCenelec
    autoload :Builder, "#{__dir__}/cen_cenelec/builder"
    autoload :Identifier, "#{__dir__}/cen_cenelec/identifier"
    autoload :Identifiers, "#{__dir__}/cen_cenelec/identifiers"
    autoload :Parser, "#{__dir__}/cen_cenelec/parser"
    autoload :Renderer, "#{__dir__}/cen_cenelec/renderer"
    autoload :Scheme, "#{__dir__}/cen_cenelec/scheme"
    autoload :SingleIdentifier, "#{__dir__}/cen_cenelec/single_identifier"
    autoload :SupplementIdentifier,
             "#{__dir__}/cen_cenelec/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/cen_cenelec/urn_generator"

    def self.parse(identifier)
      CenCenelec::Identifier.parse(identifier)
    end

    # Auto-discover all identifier types from the Identifiers namespace
    # @return [Array<Class>] identifier classes that define a self.type Hash
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c.respond_to?(:type) }
        .select { |c| c.type.is_a?(Hash) }
    end

    # Build typed stage index from the Scheme's TYPED_STAGES_REGISTRY
    # @return [Array<Pubid::Components::TypedStage>] all typed stages
    def self.all_typed_stages
      @all_typed_stages ||= Scheme::TYPED_STAGES_REGISTRY
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

Pubid::Registry.register(:cen_cenelec, Pubid::CenCenelec)

# Per-flavor format registry: inherits global formats, overrides :human
# Register on both root hierarchies: SingleIdentifier and Identifiers::Base
cen_renderer = Pubid::CenCenelec::Renderer
Pubid::CenCenelec::SingleIdentifier.format_registry = Pubid::FormatRegistry.new(parent: Pubid::Identifier.format_registry)
Pubid::CenCenelec::SingleIdentifier.format_registry.register(:human, renderer: cen_renderer)
Pubid::CenCenelec::Identifiers::Base.format_registry = Pubid::FormatRegistry.new(parent: Pubid::Identifier.format_registry)
Pubid::CenCenelec::Identifiers::Base.format_registry.register(:human, renderer: cen_renderer)
