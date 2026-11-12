# frozen_string_literal: true
#
# PFS-generated flavor — DO NOT EDIT BY HAND.
# Source: definitions/cen.pfs (pfs:1) sha256:bc1edd5874f8938b5f946416a2b052d9d9b9df3d99f6c20a3d88fcab9ae1d70c
# Compiler: pubid/grammar/pfs 0.1.0 (baked with parsanol 1.3.126)
# Regenerate: ruby scripts/pfs compile definitions/cen.pfs --as cen_pfs --ruby-out <dir>

require "pubid"

module Pubid
  # CEN/CENELEC European Norms (module composition) flavor, compiled from its PFS definition
  # (pubid/pubid#706). A compiled flavor is a peer of the coded
  # flavors: same registry, same input guards, same error
  # namespace, same URN contracts.
  module CenPfs
    extend Pubid::PrefixesSupport

    PREFIXES = ["EN", "CEN/", "CLC/"].freeze
    # The module composition the definition binds (issue #706 §4):
    # each entry names the library module, the version it was bound
    # at, and — where the module declares one — its IDENTITY
    # composition (wrapper-with-adopted: the adopted document is
    # the base). Carried so consumers and the wizard can
    # introspect what the flavor is composed of.
    MODULES = [
      { name: "iso.inner", version: 1, identity: { composition: "wrapper-with-adopted", base_module: "iso.inner", adopted_field: :adopted } },
      { name: "en.overlay", version: 1, identity: { composition: "wrapper-with-adopted", base_module: "iso.inner", adopted_field: :adopted } },
      { name: "national.prefix", version: 1, identity: { composition: "wrapper-with-adopted", base_module: "iso.inner", adopted_field: :adopted } },
      { name: "supplements.core", version: 1, identity: { composition: "wrapper-with-adopted", adopted_field: :base } },
    ].freeze

    autoload :Builder, "#{__dir__}/cen_pfs/builder"
    autoload :Identifier, "#{__dir__}/cen_pfs/identifier"
    autoload :Identifiers, "#{__dir__}/cen_pfs/identifiers"
    autoload :Parser, "#{__dir__}/cen_pfs/parser"
    autoload :Renderer, "#{__dir__}/cen_pfs/renderer"
    autoload :PubidUrnSchema, "#{__dir__}/cen_pfs/pubid_urn_schema"
    autoload :UrnGenerator, "#{__dir__}/cen_pfs/urn_generator"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: CenPfs::Renderer)

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

Pubid::Registry.register(:cen_pfs, Pubid::CenPfs)
