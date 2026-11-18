# frozen_string_literal: true

require "pubid"
module Pubid
  # arXiv flavor — e-print identifiers per
  # https://info.arxiv.org/help/arxiv_identifier_for_services.html
  #
  # Parses the new form (`2301.00001v1`, `0704.0001`) and the old form
  # (`hep-th/9901001`, `math.GT/0309136`), each with an optional
  # case-insensitive `arXiv:` or `arXiv ` prefix. A missing version is a
  # wildcard under `===`, so `arXiv:2301.00001` matches every version.
  module Arxiv
    extend Pubid::PrefixesSupport

    PREFIXES = ["arXiv"].freeze

    autoload :Builder, "#{__dir__}/arxiv/builder"
    autoload :Identifier, "#{__dir__}/arxiv/identifier"
    autoload :Identifiers, "#{__dir__}/arxiv/identifiers"
    autoload :Parser, "#{__dir__}/arxiv/parser"
    autoload :Renderer, "#{__dir__}/arxiv/renderer"
    autoload :PubidUrnSchema, "#{__dir__}/arxiv/pubid_urn_schema"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Arxiv::Renderer)

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

Pubid::Registry.register(:arxiv, Pubid::Arxiv)
