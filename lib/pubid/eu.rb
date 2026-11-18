# frozen_string_literal: true

require "pubid"
module Pubid
  # EU legal acts: regulations, directives and decisions (CELEX sector 3).
  #
  #   EU Regulation 1227/2011    canonical, pre-2015 regulation: number/year
  #   EU Regulation 2016/679     canonical, from 2015: year/number
  #   EU Directive 2016/680      canonical, directives: year/number
  #
  # Parse-only alternates: the Official Journal long form
  # (`Regulation (EU) No 1227/2011`), CELEX (`32011R1227`) and ELI
  # (`http://data.europa.eu/eli/reg/2011/1227/oj`). See lib/pubid/eu/CLAUDE.md.
  module Eu
    extend Pubid::PrefixesSupport

    PREFIXES = ["EU"].freeze

    autoload :Builder, "#{__dir__}/eu/builder"
    autoload :Identifier, "#{__dir__}/eu/identifier"
    autoload :Identifiers, "#{__dir__}/eu/identifiers"
    autoload :Parser, "#{__dir__}/eu/parser"
    autoload :Renderer, "#{__dir__}/eu/renderer"
    autoload :PubidUrnSchema, "#{__dir__}/eu/pubid_urn_schema"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    Identifier.format_registry =
      FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Eu::Renderer)

    def self.identifier_types
      [Identifiers::Regulation, Identifiers::Directive, Identifiers::Decision]
    end

    def self.all_typed_stages
      []
    end

    def self.locate_type(code)
      identifier_types.find { |t| t.type[:key].to_s == code.to_s }
    end

    def self.locate_stage(_abbr)
      nil
    end
  end
end

Pubid::Registry.register(:eu, Pubid::Eu)
