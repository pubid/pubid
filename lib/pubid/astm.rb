# frozen_string_literal: true

module Pubid
  module Astm
    autoload :Components, "#{__dir__}/astm/components"
    autoload :Identifier, "#{__dir__}/astm/identifier"
    autoload :Identifiers, "#{__dir__}/astm/identifiers"
    autoload :SingleIdentifier, "#{__dir__}/astm/single_identifier"
    autoload :Parser, "#{__dir__}/astm/parser"
    autoload :Builder, "#{__dir__}/astm/builder"
    autoload :Renderer, "#{__dir__}/astm/renderer"
    autoload :UrnGenerator, "#{__dir__}/astm/urn_generator"
    autoload :UrnParser, "#{__dir__}/astm/urn_parser"

    def self.parse(str)
      Identifier.parse(str)
    end

    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c.singleton_methods(false).include?(:type) }
        .select { |c| c.type.is_a?(Hash) }
    end

    def self.all_typed_stages
      @all_typed_stages ||= identifier_types.flat_map do |klass|
        if klass.const_defined?(:TYPED_STAGES)
          klass.const_get(:TYPED_STAGES)
        else
          []
        end
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

Pubid::Registry.register(:astm, Pubid::Astm)

Pubid::Astm::SingleIdentifier.format_registry = Pubid::FormatRegistry.new(parent: Pubid::Identifier.format_registry)
Pubid::Astm::SingleIdentifier.format_registry.register(:human, renderer: Pubid::Astm::Renderer)
