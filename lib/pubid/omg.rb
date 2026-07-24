# frozen_string_literal: true

module Pubid
  # OMG (Object Management Group) specification flavor.
  #
  # Covers formal OMG specifications identified by an acronym (UML, SysML,
  # CORBA, AMI4CCM, ...) with optional version (`1.0`, `2.5.1`,
  # `5 beta 3`).
  module Omg
    extend Pubid::PrefixesSupport

    PREFIXES = ["OMG"].freeze

    autoload :Builder, "#{__dir__}/omg/builder"
    autoload :Identifier, "#{__dir__}/omg/identifier"
    autoload :Identifiers, "#{__dir__}/omg/identifiers"
    autoload :Parser, "#{__dir__}/omg/parser"
    autoload :Renderer, "#{__dir__}/omg/renderer"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Omg::Renderer)

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

Pubid::Registry.register(:omg, Pubid::Omg)
