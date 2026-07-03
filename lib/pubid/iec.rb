# frozen_string_literal: true

module Pubid
  module Iec
    autoload :Components, "#{__dir__}/iec/components"
    autoload :Identifier, "#{__dir__}/iec/identifier"
    autoload :Identifiers, "#{__dir__}/iec/identifiers"
    autoload :SingleIdentifier, "#{__dir__}/iec/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/iec/supplement_identifier"
    autoload :Parser, "#{__dir__}/iec/parser"
    autoload :Builder, "#{__dir__}/iec/builder"
    autoload :UrnParser, "#{__dir__}/iec/urn_parser"
    autoload :UrnGenerator, "#{__dir__}/iec/urn_generator"
    autoload :RenderingStyle, "#{__dir__}/iec/rendering_style"
    autoload :Renderer, "#{__dir__}/iec/renderer"

    def self.parse(identifier_string)
      if identifier_string.length > Pubid::MAX_INPUT_LENGTH
        raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
      end

      parsed = Parser.new.parse(identifier_string)
      Builder.new.build(parsed)
    end

    def self.parse_urn(urn)
      UrnParser.parse(urn)
    end

    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Iec::Renderer)

    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c.singleton_methods(false).include?(:type) }
        .select { |c| begin; c.type.is_a?(Hash); rescue NotImplementedError; false; end }
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

Pubid::Registry.register(:iec, Pubid::Iec)
