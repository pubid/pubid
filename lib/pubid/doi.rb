# frozen_string_literal: true

module Pubid
  # DOI (Digital Object Identifier) flavor.
  #
  # Parses the canonical DOI per ISO 26324:
  #   doi:10.{REGISTRAR}/{SUFFIX}
  #
  # The optional URL form `https://doi.org/10.X/Y` is accepted; the resolver
  # host is stripped before parsing.
  module Doi
    extend Pubid::PrefixesSupport

    # Leading tokens a DOI string can start with. The bare "10." form is the
    # canonical prefix per ISO 26324 §4.1.
    PREFIXES = %w[doi: DOI: 10.].freeze

    autoload :Builder, "#{__dir__}/doi/builder"
    autoload :Identifier, "#{__dir__}/doi/identifier"
    autoload :Identifiers, "#{__dir__}/doi/identifiers"
    autoload :Parser, "#{__dir__}/doi/parser"
    autoload :Renderer, "#{__dir__}/doi/renderer"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Doi::Renderer)

    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c.singleton_methods(false).include?(:type) }
        .select { |c| c.type.is_a?(Hash) }
    end

    def self.all_typed_stages
      @all_typed_stages ||= identifier_types.flat_map do |klass|
        klass.const_defined?(:TYPED_STAGES) ? klass.const_get(:TYPED_STAGES) : []
      end
    end

    def self.locate_type(code)
      identifier_types.find { |t| t.type[:key].to_s == code.to_s }
    end

    def self.locate_stage(abbr)
      abbr_str = abbr.to_s.upcase
      all_typed_stages.find { |s| s.abbr.any? { |a| a.to_s.upcase == abbr_str } }
    end
  end
end

Pubid::Registry.register(:doi, Pubid::Doi)
