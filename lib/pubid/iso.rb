# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Iso
    autoload :Builder, "#{__dir__}/iso/builder"
    autoload :BundledIdentifier, "#{__dir__}/iso/bundled_identifier"
    autoload :CombinedIdentifier, "#{__dir__}/iso/combined_identifier"
    autoload :Components, "#{__dir__}/iso/components"
    autoload :FormatResolver, "#{__dir__}/iso/format_resolver"
    autoload :Identifier, "#{__dir__}/iso/identifier"
    autoload :Identifiers, "#{__dir__}/iso/identifiers"
    autoload :Parser, "#{__dir__}/iso/parser"
    autoload :RenderingStyle, "#{__dir__}/iso/rendering_style"
    autoload :Scheme, "#{__dir__}/iso/scheme"
    autoload :SingleIdentifier, "#{__dir__}/iso/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/iso/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/iso/urn_generator"
    autoload :UrnParser, "#{__dir__}/iso/urn_parser"
    autoload :Utilities, "#{__dir__}/iso/utilities"

    # Parse an ISO identifier string
    # @param identifier [String] the identifier string to parse
    # @param format [Symbol] :auto, :human, :mr_string, or :urn
    # @return [Identifier] the parsed identifier
    def self.parse(identifier, format: :auto)
      format = Pubid::FormatDetector.detect(identifier) if format == :auto

      case format
      when :urn
        UrnParser.parse(identifier)
      when :mr_string
        Pubid::Parsers::MrString.parse(identifier)
      else
        Scheme.parse(identifier)
      end
    end

    # Parse an ISO URN string
    # @param urn [String] the URN string to parse
    # @return [Identifier] the parsed identifier
    # @raise [Errors::ParseError] if URN is invalid
    def self.parse_urn(urn)
      UrnParser.parse(urn)
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

Pubid::Registry.register(:iso, Pubid::Iso)
