# frozen_string_literal: true

module Pubid
  module Un
    extend Pubid::PrefixesSupport

    PREFIXES = ["UN"].freeze

    autoload :Builder, "#{__dir__}/un/builder"
    autoload :Identifier, "#{__dir__}/un/identifier"
    autoload :Identifiers, "#{__dir__}/un/identifiers"
    autoload :Parser, "#{__dir__}/un/parser"
    autoload :Renderer, "#{__dir__}/un/renderer"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Un::Renderer)

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

Pubid::Registry.register(:un, Pubid::Un)
