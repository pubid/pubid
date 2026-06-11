# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Itu
    autoload :Builder, "#{__dir__}/itu/builder"
    autoload :Components, "#{__dir__}/itu/components"
    autoload :Identifier, "#{__dir__}/itu/identifier"
    autoload :Identifiers, "#{__dir__}/itu/identifiers"
    autoload :Parser, "#{__dir__}/itu/parser"
    autoload :Scheme, "#{__dir__}/itu/scheme"
    autoload :UrnGenerator, "#{__dir__}/itu/urn_generator"
    autoload :Model, "#{__dir__}/itu/model"

    # I18N is a YAML-loaded constant (not a class), so autoload cannot be used.
    # It is loaded eagerly when the ITU module is first referenced.
    require "#{__dir__}/itu/i18n"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    # Auto-discover all identifier types from the Identifiers namespace
    # @return [Array<Class>] identifier classes that define a self.type Hash
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c.respond_to?(:type) }
        .select { |c| c.type.is_a?(Hash) }
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

# Register ITU flavor with the registry
Pubid::Registry.register(:itu, Pubid::Itu)
