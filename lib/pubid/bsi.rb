# frozen_string_literal: true

module Pubid
  module Bsi
    module Components
      autoload :Code, "#{__dir__}/bsi/components/code"
      autoload :Date, "#{__dir__}/bsi/components/date"
      autoload :Publisher, "#{__dir__}/bsi/components/publisher"
      autoload :Type, "#{__dir__}/bsi/components/type"
    end

    autoload :Builder, "#{__dir__}/bsi/builder"
    autoload :Identifier, "#{__dir__}/bsi/identifier"
    autoload :Identifiers, "#{__dir__}/bsi/identifiers"
    autoload :Model, "#{__dir__}/bsi/model"
    autoload :Parser, "#{__dir__}/bsi/parser"
    autoload :Renderer, "#{__dir__}/bsi/renderer"
    autoload :Scheme, "#{__dir__}/bsi/scheme"
    autoload :SingleIdentifier, "#{__dir__}/bsi/single_identifier"
    autoload :UrnGenerator, "#{__dir__}/bsi/urn_generator"

    def self.parse(string)
      Identifier.parse(string)
    end

    def self.transform(data)
      Builder.build(data)
    end

    # Auto-discover all identifier types from the Identifiers namespace
    # @return [Array<Class>] identifier classes that define a self.type Hash
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c.respond_to?(:type) }
        .select { |c| c.type.is_a?(Hash) }
    end

    # Build typed stage index from the Scheme's TYPED_STAGES_REGISTRY
    # @return [Array<Pubid::Components::TypedStage>] all typed stages
    def self.all_typed_stages
      @all_typed_stages ||= Scheme::TYPED_STAGES_REGISTRY
    end

    # Lookup: type code -> identifier class
    # @param code [String, Symbol] the type key to find
    # @return [Class, nil] the matching identifier class
    def self.locate_type(code)
      identifier_types.find { |t| t.type[:key].to_s == code.to_s }
    end

    # Lookup: abbreviation -> typed stage
    # @param abbr [String, Symbol] the abbreviation to find
    # @return [Pubid::Components::TypedStage, nil] the matching typed stage
    def self.locate_stage(abbr)
      abbr_str = abbr.to_s.upcase
      all_typed_stages.find { |s| s.abbr.any? { |a| a.to_s.upcase == abbr_str } }
    end
  end
end

# Register Ubsi flavor with the registry
Pubid::Registry.register(:bsi, Pubid::Bsi)

# Per-flavor format registry: inherits global formats, overrides :human
Pubid::Bsi::Identifiers::Base.format_registry = Pubid::FormatRegistry.new(parent: Pubid::Identifier.format_registry)
Pubid::Bsi::Identifiers::Base.format_registry.register(:human, renderer: Pubid::Bsi::Renderer)
Pubid::Bsi::SingleIdentifier.format_registry = Pubid::Bsi::Identifiers::Base.format_registry
