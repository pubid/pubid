# frozen_string_literal: true
#
# PFS-generated flavor — DO NOT EDIT BY HAND.
# Source: definitions/doi.pfs (pfs:1) sha256:60abc3c403c61019d727ee44d9a72591c1549672451e6609a72d36189cae6340
# Compiler: pubid/grammar/pfs 0.1.0 (baked with parsanol 1.3.126)
# Regenerate: ruby scripts/pfs compile definitions/doi.pfs --as doi_pfs --ruby-out <dir>

require "pubid"

module Pubid
  # Digital Object Identifier flavor, compiled from its PFS definition
  # (pubid/pubid#706). A compiled flavor is a peer of the coded
  # flavors: same registry, same input guards, same error
  # namespace, same URN contracts.
  module DoiPfs
    extend Pubid::PrefixesSupport

    PREFIXES = ["doi:", "DOI:", "10."].freeze
    

    autoload :Builder, "#{__dir__}/doi_pfs/builder"
    autoload :Identifier, "#{__dir__}/doi_pfs/identifier"
    autoload :Identifiers, "#{__dir__}/doi_pfs/identifiers"
    autoload :Parser, "#{__dir__}/doi_pfs/parser"
    autoload :Renderer, "#{__dir__}/doi_pfs/renderer"
    autoload :PubidUrnSchema, "#{__dir__}/doi_pfs/pubid_urn_schema"
    autoload :UrnGenerator, "#{__dir__}/doi_pfs/urn_generator"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: DoiPfs::Renderer)

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

Pubid::Registry.register(:doi_pfs, Pubid::DoiPfs)
