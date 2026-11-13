# frozen_string_literal: true
#
# PFS-generated flavor — DO NOT EDIT BY HAND.
# Source: definitions/etsi.pfs (pfs:1) sha256:490ba9435f44dbd2d59429ae6d9527909c39444f19fec5a33a8cad91e89e3581
# Compiler: pubid/grammar/pfs 0.1.0 (baked with parsanol 1.3.126)
# Regenerate: ruby scripts/pfs compile definitions/etsi.pfs --as etsi_pfs --ruby-out <dir>

require "pubid"

module Pubid
  # ETSI flavor, compiled from its PFS definition
  # (pubid/pubid#706). A compiled flavor is a peer of the coded
  # flavors: same registry, same input guards, same error
  # namespace, same URN contracts.
  module EtsiPfs
    extend Pubid::PrefixesSupport

    PREFIXES = ["ETSI"].freeze
    

    autoload :Builder, "#{__dir__}/etsi_pfs/builder"
    autoload :Identifier, "#{__dir__}/etsi_pfs/identifier"
    autoload :Identifiers, "#{__dir__}/etsi_pfs/identifiers"
    autoload :Parser, "#{__dir__}/etsi_pfs/parser"
    autoload :Renderer, "#{__dir__}/etsi_pfs/renderer"
    autoload :PubidUrnSchema, "#{__dir__}/etsi_pfs/pubid_urn_schema"
    autoload :UrnGenerator, "#{__dir__}/etsi_pfs/urn_generator"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: EtsiPfs::Renderer)

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

Pubid::Registry.register(:etsi_pfs, Pubid::EtsiPfs)
