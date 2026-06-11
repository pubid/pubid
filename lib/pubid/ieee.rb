# frozen_string_literal: true

module Pubid
  module Ieee
    autoload :Aiee, "#{__dir__}/ieee/aiee"
    autoload :Builder, "#{__dir__}/ieee/builder"
    autoload :Identifier, "#{__dir__}/ieee/identifier"
    autoload :Identifiers, "#{__dir__}/ieee/identifiers"
    autoload :Ire, "#{__dir__}/ieee/ire"
    autoload :Nesc, "#{__dir__}/ieee/nesc"
    autoload :Parser, "#{__dir__}/ieee/parser"
    autoload :Renderer, "#{__dir__}/ieee/renderer"
    autoload :Scheme, "#{__dir__}/ieee/scheme"
    autoload :TypedStages, "#{__dir__}/ieee/typed_stages"
    autoload :UrnGenerator, "#{__dir__}/ieee/urn_generator"

    # Components submodule
    module Components
      autoload :Code, "#{__dir__}/ieee/components/code"
      autoload :Draft, "#{__dir__}/ieee/components/draft"
      autoload :Relationship, "#{__dir__}/ieee/components/relationship"
      autoload :TypedStage, "#{__dir__}/ieee/components/typed_stage"
    end

    class << self
      def parse(input)
        Identifier.parse(input)
      end

      # Auto-discover all identifier types from the Identifiers namespace
      # @return [Array<Class>] identifier classes that define a self.type Hash
      def identifier_types
        @identifier_types ||= Identifiers.constants
          .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
          .select { |c| c.is_a?(Class) && c.respond_to?(:type) }
          .select { |c| c.type.is_a?(Hash) }
      end

      # Build typed stage index from TypedStages module
      # @return [Array<Pubid::Components::TypedStage>] all typed stages
      def all_typed_stages
        @all_typed_stages ||= TypedStages::TYPED_STAGES
      end

      # Lookup: type code -> identifier class
      # @param code [String, Symbol] the type key to find
      # @return [Class, nil] the matching identifier class
      def locate_type(code)
        identifier_types.find { |t| t.type[:key].to_s == code.to_s }
      end

      # Lookup: abbreviation -> typed stage
      # @param abbr [String, Symbol] the abbreviation to find
      # @return [Pubid::Components::TypedStage, nil] the matching typed stage
      def locate_stage(abbr)
        abbr_str = abbr.to_s.upcase
        all_typed_stages.find { |s| s.abbr.any? { |a| a.to_s.upcase == abbr_str } }
      end
    end
  end
end

Pubid::Registry.register(:ieee, Pubid::Ieee)

# Per-flavor format registry: inherits global formats, overrides :human
Pubid::Ieee::Identifiers::Base.format_registry = Pubid::FormatRegistry.new(parent: Pubid::Identifier.format_registry)
Pubid::Ieee::Identifiers::Base.format_registry.register(:human, renderer: Pubid::Ieee::Renderer)
