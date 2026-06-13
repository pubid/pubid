# frozen_string_literal: true

module Pubid
  module Api
    autoload :Builder, "#{__dir__}/api/builder"
    autoload :Identifier, "#{__dir__}/api/identifier"
    autoload :Identifiers, "#{__dir__}/api/identifiers"
    autoload :Parser, "#{__dir__}/api/parser"
    autoload :Renderer, "#{__dir__}/api/renderer"
    autoload :SingleIdentifier, "#{__dir__}/api/single_identifier"

    def self.parse(input)
      Identifier.parse(input)
    end

    # Auto-discover all identifier types from the Identifiers namespace.
    # @return [Array<Class>] identifier classes (Pubid::Identifier subclasses)
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c < Pubid::Identifier }
        .reject { |c| c.name&.split("::")&.last == "Base" }
    end

    # Build typed stage index from identifier types
    # @return [Array<Pubid::Components::TypedStage>] all typed stages
    def self.all_typed_stages
      @all_typed_stages ||= identifier_types.flat_map do |klass|
        if klass.const_defined?(:TYPED_STAGES)
          klass.const_get(:TYPED_STAGES)
        else
          []
        end
      end
    end

    # Lookup: type code -> identifier class
    # @param code [String, Symbol] the type key to find
    # @return [Class, nil] the matching identifier class
    def self.locate_type(code)
      identifier_types.find { |t| t.type[:key].to_s == code.to_s }
    rescue NoMethodError
      nil
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

# Register Uapi flavor with the registry
Pubid::Registry.register(:api, Pubid::Api)

# Per-flavor format registry: inherits global formats, overrides :human
Pubid::Api::Identifiers::Base.format_registry = Pubid::FormatRegistry.new(parent: Pubid::Identifier.format_registry)
Pubid::Api::Identifiers::Base.format_registry.register(:human, renderer: Pubid::Api::Renderer)
