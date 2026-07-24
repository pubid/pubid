# frozen_string_literal: true

module Pubid
  # Chinese Standard (GB) flavor.
  #
  # Covers national (GB), sector/industry (DB, QB, ZB, HB, JB, NY, YY, HJ,
  # CJ, JG, MH, SL, DL, TB, TD, ...) and social-group (T/{ORG}) standards
  # issued under the Chinese standards system. The mandate category is
  # carried after a slash: T (recommended), Z (guideline), or omitted
  # (mandatory).
  module Gb
    extend Pubid::PrefixesSupport

    # Leading tokens a printed Chinese Standard identifier may start with.
    # Used by relaton to route reference strings to this flavor. National
    # "GB" comes first so PrefixesSupport's longest-match wins.
    PREFIXES = %w[
      GB GB/T GB/Z
      DB DB/T DB/Z
      QB QB/T
      ZB ZB/T
      HB HB/T
      JB JB/T
      NY NY/T
      YY YY/T
      HJ HJ/T
      CJ CJ/T
      JG JG/T
      MH MH/T
      SL SL/T
      DL DL/T
      TB TB/T
      TD TD/T
      T/
    ].freeze

    autoload :Builder, "#{__dir__}/gb/builder"
    autoload :Identifier, "#{__dir__}/gb/identifier"
    autoload :Identifiers, "#{__dir__}/gb/identifiers"
    autoload :Parser, "#{__dir__}/gb/parser"
    autoload :Renderer, "#{__dir__}/gb/renderer"

    # Parse a Chinese Standard identifier string.
    # @param identifier [String] e.g. "GB/T 20223-2006"
    # @return [Pubid::Gb::Identifier]
    def self.parse(identifier)
      Identifier.parse(identifier)
    end

    Identifier.format_registry = FormatRegistry.new(parent: Identifier.format_registry)
    Identifier.format_registry.register(:human, renderer: Gb::Renderer)

    # Auto-discover concrete identifier types.
    # @return [Array<Class>]
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map do |c| 
        
        Identifiers.const_get(c); rescue NameError; nil 
        
      end
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
      all_typed_stages.find do |s| 
        s.abbr.any? do |a|
          a.to_s.upcase == abbr_str
        end
      end
    end
  end
end

Pubid::Registry.register(:gb, Pubid::Gb)
