# frozen_string_literal: true
#
# PFS-generated flavor — DO NOT EDIT BY HAND.
# Source: definitions/bsi.pfs (pfs:1) sha256:acb28ac064cf70b7dcaf8ec199cd535f95c201ca348746f9124ce7d080473585
# Compiler: pubid/grammar/pfs 0.1.0 (baked with parsanol 1.3.126)
# Regenerate: ruby scripts/pfs compile definitions/bsi.pfs --as bsi_pfs --ruby-out <dir>

require "pubid"

module Pubid
  # BSI (module composition) flavor, compiled from its PFS definition
  # (pubid/pubid#706). A compiled flavor is a peer of the coded
  # flavors: same registry, same input guards, same error
  # namespace, same URN contracts.
  module BsiPfs
    extend Pubid::PrefixesSupport

    PREFIXES = ["BS", "PAS", "PD", "DD", "TS"].freeze
    # The module composition the definition binds (issue #706 §4):
    # each entry names the library module, the version it was bound
    # at, and — where the module declares one — its IDENTITY
    # composition (wrapper-with-adopted: the adopted document is
    # the base). Carried so consumers and the wizard can
    # introspect what the flavor is composed of.
    MODULES = [
      { name: "iso.inner", version: 1, identity: { composition: "wrapper-with-adopted", base_module: "iso.inner", adopted_field: :adopted } },
      { name: "iec.inner", version: 1, identity: { composition: "wrapper-with-adopted", base_module: "iec.inner", adopted_field: :adopted } },
      { name: "en.overlay", version: 1, identity: { composition: "wrapper-with-adopted", base_module: "iso.inner", adopted_field: :adopted } },
      { name: "national.prefix", version: 1, identity: { composition: "wrapper-with-adopted", base_module: "iso.inner", adopted_field: :adopted } },
      { name: "supplements.core", version: 1, identity: { composition: "wrapper-with-adopted", adopted_field: :base } },
    ].freeze
    # The adopted-base dispatch hook (the §4 coded escape hatch):
    # vendored beside the generated classes — a missing hook file
    # fails loudly on the first adoption, never silently.
    autoload :AdoptedBase, "#{__dir__}/bsi_pfs/adopted_base"
    autoload :Builder, "#{__dir__}/bsi_pfs/builder"
    autoload :Identifier, "#{__dir__}/bsi_pfs/identifier"
    autoload :Identifiers, "#{__dir__}/bsi_pfs/identifiers"
    autoload :Parser, "#{__dir__}/bsi_pfs/parser"
    autoload :Renderer, "#{__dir__}/bsi_pfs/renderer"
    autoload :PubidUrnSchema, "#{__dir__}/bsi_pfs/pubid_urn_schema"
    autoload :UrnGenerator, "#{__dir__}/bsi_pfs/urn_generator"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: BsiPfs::Renderer)

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

Pubid::Registry.register(:bsi_pfs, Pubid::BsiPfs)
