# frozen_string_literal: true

require "pubid"
module Pubid
  # WMO (World Meteorological Organization) document identifiers
  # (pubid#763): the WMO-No. publication series and, since the JCOMM
  # dissolution, the WMO-published S-100-family product specifications.
  #
  #   WMO-No. 1364                      the WMO-No. series, bare
  #   WMO-No. 1364, 2025 edition        year edition (calendar years)
  #   S-411                             WMO-published S-100 spec, bare
  #   S-411 1.2.1                       dotted edition (the S-411 repo form)
  #   S-411 Annex A                     annex wrapper (the DCEG docidentifier)
  #
  # The S-lexical type assignment is the #763 ruling: the lexical shape is
  # the IHO S-100 form, but the flavor owns the WMO-published documents —
  # the same publisher-parameterised split as IALA's S-201 (Pubid::Iala,
  # urn:mrn:iala:pub:s-201:ed2.0.0). See lib/pubid/wmo/CLAUDE.md.
  module Wmo
    extend Pubid::PrefixesSupport

    # The leading series token of the WMO-No. publication series. The
    # S-100 lexical form ("S-411") deliberately leads NO prefix: a bare
    # S-number is the shared S-100 shape of two assigning authorities
    # (IHO and WMO), so each flavor parses it and neither owns the
    # routing (the pubid#469 dual-perspective policy).
    PREFIXES = ["WMO-No."].freeze

    autoload :Builder,        "#{__dir__}/wmo/builder"
    autoload :Identifier,     "#{__dir__}/wmo/identifier"
    autoload :Identifiers,    "#{__dir__}/wmo/identifiers"
    autoload :Parser,         "#{__dir__}/wmo/parser"
    autoload :Renderer,       "#{__dir__}/wmo/renderer"
    autoload :UrnGenerator,   "#{__dir__}/wmo/urn_generator"
    autoload :UrnParser,      "#{__dir__}/wmo/urn_parser"
    autoload :PubidUrnSchema, "#{__dir__}/wmo/pubid_urn_schema"

    # Parse a WMO identifier string into an identifier object.
    # @param identifier [String] The WMO identifier string to parse
    # @return [Pubid::Wmo::Identifier]
    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    # Per-flavor format registry: inherits global formats, overrides :human
    Identifier.format_registry = FormatRegistry.new(parent: ::Pubid::Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Wmo::Renderer)

    # Auto-discover all identifier types from the Identifiers namespace.
    # @return [Array<Class>] identifier classes (Pubid::Identifier subclasses)
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| resolve_identifier_constant(c) }
    end

    # One Identifiers constant as an identifier class, or nil: a constant
    # that does not resolve, or resolves to anything but a Pubid::Identifier
    # subclass, is not a type.
    # @param const [Symbol]
    # @return [Class, nil]
    def self.resolve_identifier_constant(const)
      klass = Identifiers.const_get(const)
      return if !klass.is_a?(Class) || !(klass < Pubid::Identifier)

      klass unless klass == Identifier
    rescue NameError
      nil
    end

    # WMO identifiers carry no typed stages.
    # @return [Array<Pubid::Components::TypedStage>]
    def self.all_typed_stages
      []
    end

    # Lookup: type code -> identifier class
    # @param code [String, Symbol]
    # @return [Class, nil]
    def self.locate_type(code)
      identifier_types.find { |t| t.type[:key].to_s == code.to_s }
    end

    # WMO identifiers carry no typed stages.
    # @param _abbr [String, Symbol]
    # @return [nil]
    def self.locate_stage(_abbr)
      nil
    end
  end
end

Pubid::Registry.register(:wmo, Pubid::Wmo)
