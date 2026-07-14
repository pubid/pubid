# frozen_string_literal: true

module Pubid
  module Easc
    extend Pubid::PrefixesSupport

    # Leading identifier tokens that an EASC document id can start with.
    # Both Cyrillic (canonical — ПМГ, РМГ) and Latin transliterations
    # (PMG, RMG) are accepted; the canonical render is Cyrillic per
    # mgscatalog.by convention.
    PREFIXES = ["ПМГ", "РМГ", "PMG", "RMG"].freeze

    autoload :Builder,      "#{__dir__}/easc/builder"
    autoload :Identifier,   "#{__dir__}/easc/identifier"
    autoload :Identifiers,  "#{__dir__}/easc/identifiers"
    autoload :Parser,       "#{__dir__}/easc/parser"
    autoload :Renderer,     "#{__dir__}/easc/renderer"
    autoload :UrnGenerator, "#{__dir__}/easc/urn_generator"
    autoload :UrnParser,    "#{__dir__}/easc/urn_parser"

    # @param identifier [String]
    # @return [Pubid::Easc::Identifier]
    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    # Per-flavor format registry.
    Identifiers::Base.format_registry = FormatRegistry.new(parent: ::Pubid::Identifier.format_registry)
    Identifiers::Base.format_registry.register(:human, renderer: Easc::Renderer)

    # Auto-discover identifier types from the Identifiers namespace.
    # @return [Array<Class>]
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c < Pubid::Identifier }
        .reject { |c| c == Identifiers::Base }
    end

    # Lookup: series (ПМГ / РМГ / PMG / RMG) → identifier class
    # @param series [String, Symbol]
    # @return [Class<Identifiers::Base>, nil]
    def self.identifier_klass_for_series(series)
      @by_series ||= identifier_types.to_h do |klass|
        [klass.type[:series].to_s, klass]
      end
      @by_series[series.to_s] || @by_series[series.to_s.upcase]
    end
  end
end

Pubid::Registry.register(:easc, Pubid::Easc)
