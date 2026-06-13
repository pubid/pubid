# frozen_string_literal: true

module Pubid
  module Cie
    module Components
      autoload :Code, "#{__dir__}/cie/components/code"
      autoload :Language, "#{__dir__}/cie/components/language"
    end

    autoload :Builder, "#{__dir__}/cie/builder"
    autoload :Identifier, "#{__dir__}/cie/identifier"
    autoload :Identifiers, "#{__dir__}/cie/identifiers"
    autoload :Parser, "#{__dir__}/cie/parser"
    autoload :SingleIdentifier, "#{__dir__}/cie/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/cie/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/cie/urn_generator"

    # Main entry point for CIE identifiers
    # Delegates to Identifier.parse
    def self.parse(input)
      Identifier.parse(input)
    end

    # Auto-discover all identifier types from the Identifiers namespace.
    # CIE identifier classes extend Lutaml::Model::Serializable via
    # SingleIdentifier / SupplementIdentifier, without a self.type Hash.
    # We discover by checking for subclasses of those base types.
    # @return [Array<Class>] identifier classes
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && (c < SingleIdentifier || c < SupplementIdentifier) }
    end

    # Build typed stage index from identifier types.
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

    # Lookup: class name -> identifier class
    # Since CIE lacks self.type, locate by class name suffix
    # @param code [String, Symbol] the type key to find
    # @return [Class, nil] the matching identifier class
    def self.locate_type(code)
      identifier_types.find do |t|
        t.name.split("::").last.gsub(/([A-Z])/, '_\1').downcase.sub(/^_/, "") == code.to_s.downcase ||
          t.name.split("::").last.downcase == code.to_s.downcase
      end
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

# Register Ucie flavor with the registry
Pubid::Registry.register(:cie, Pubid::Cie)
