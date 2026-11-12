# frozen_string_literal: true
#
# PFS-generated flavor — DO NOT EDIT BY HAND.
# Source: definitions/calconnect.pfs (pfs:1) sha256:2e864f0185a1a2f18a392f2f401ad3c9d65d1f32a9ec3f3f04f7dfca9b2226c4
# Compiler: pubid/grammar/pfs 0.1.0 (baked with parsanol 1.3.126)
# Regenerate: ruby scripts/pfs compile definitions/calconnect.pfs --as calconnect_pfs --ruby-out <dir>

require "pubid"

module Pubid
  # CalConnect Standards flavor, compiled from its PFS definition
  # (pubid/pubid#706). A compiled flavor is a peer of the coded
  # flavors: same registry, same input guards, same error
  # namespace, same URN contracts.
  module CalconnectPfs
    extend Pubid::PrefixesSupport

    PREFIXES = ["CC"].freeze
    

    autoload :Builder, "#{__dir__}/calconnect_pfs/builder"
    autoload :Identifier, "#{__dir__}/calconnect_pfs/identifier"
    autoload :Identifiers, "#{__dir__}/calconnect_pfs/identifiers"
    autoload :Parser, "#{__dir__}/calconnect_pfs/parser"
    autoload :Renderer, "#{__dir__}/calconnect_pfs/renderer"
    autoload :PubidUrnSchema, "#{__dir__}/calconnect_pfs/pubid_urn_schema"
    autoload :UrnGenerator, "#{__dir__}/calconnect_pfs/urn_generator"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: CalconnectPfs::Renderer)

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

Pubid::Registry.register(:calconnect_pfs, Pubid::CalconnectPfs)
