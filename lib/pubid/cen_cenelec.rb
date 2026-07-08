# frozen_string_literal: true

module Pubid
  module CenCenelec
    extend Pubid::PrefixesSupport

    # CEN/CENELEC publisher tokens, mirroring the parser's publisher rules
    # (lib/pubid/cen_cenelec/parser.rb). Adopted-org prefixes (ISO/IEC/CISPR)
    # are excluded — they route to their own SDOs, not to CEN.
    PREFIXES = %w[EN CEN CLC CWA HD ES CR ENV].freeze

    autoload :Builder, "#{__dir__}/cen_cenelec/builder"
    autoload :Identifier, "#{__dir__}/cen_cenelec/identifier"
    autoload :Identifiers, "#{__dir__}/cen_cenelec/identifiers"
    autoload :Parser, "#{__dir__}/cen_cenelec/parser"
    autoload :Renderer, "#{__dir__}/cen_cenelec/renderer"
    autoload :SingleIdentifier, "#{__dir__}/cen_cenelec/single_identifier"
    autoload :SupplementIdentifier,
             "#{__dir__}/cen_cenelec/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/cen_cenelec/urn_generator"
    autoload :UrnParser, "#{__dir__}/cen_cenelec/urn_parser"

    # TYPED_STAGES_REGISTRY for native CEN types
    TYPED_STAGES_REGISTRY = [
      # European Norm (EN)
      Pubid::Components::TypedStage.new(
        code: :puben,
        stage_code: :published,
        type_code: :en,
        abbr: ["EN"],
        name: "European Norm",
        harmonized_stages: %w[60.00 60.60],
      ),
      Pubid::Components::TypedStage.new(
        code: :pren,
        stage_code: :proposal,
        type_code: :en,
        abbr: ["prEN"],
        name: "Proposal European Norm",
        harmonized_stages: %w[30.00 30.20 30.60 30.92 30.98 30.99],
      ),
      Pubid::Components::TypedStage.new(
        code: :fpren,
        stage_code: :final_proposal,
        type_code: :en,
        abbr: ["FprEN"],
        name: "Final Proposal European Norm",
        harmonized_stages: %w[40.00 40.20 40.60 40.92 40.98 40.99],
      ),

      # Technical Specification (TS)
      Pubid::Components::TypedStage.new(
        code: :pubts,
        stage_code: :published,
        type_code: :ts,
        abbr: ["TS"],
        name: "Technical Specification",
        harmonized_stages: %w[60.00 60.60],
      ),
      Pubid::Components::TypedStage.new(
        code: :prts,
        stage_code: :proposal,
        type_code: :ts,
        abbr: ["prTS"],
        name: "Proposal Technical Specification",
        harmonized_stages: %w[30.00 30.20 30.60 30.92 30.98 30.99],
      ),

      # Technical Report (TR)
      Pubid::Components::TypedStage.new(
        code: :pubtr,
        stage_code: :published,
        type_code: :tr,
        abbr: ["TR"],
        name: "Technical Report",
        harmonized_stages: %w[60.00 60.60],
      ),

      # CEN Workshop Agreement (CWA)
      Pubid::Components::TypedStage.new(
        code: :pubcwa,
        stage_code: :published,
        type_code: :cwa,
        abbr: ["CWA"],
        name: "CEN Workshop Agreement",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Guide
      Pubid::Components::TypedStage.new(
        code: :pubguide,
        stage_code: :published,
        type_code: :guide,
        abbr: ["Guide"],
        name: "Guide",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Harmonization Document (HD)
      Pubid::Components::TypedStage.new(
        code: :pubhd,
        stage_code: :published,
        type_code: :hd,
        abbr: ["HD"],
        name: "Harmonization Document",
        harmonized_stages: %w[60.00 60.60],
      ),

      # European Specification (ES)
      Pubid::Components::TypedStage.new(
        code: :pubes,
        stage_code: :published,
        type_code: :es,
        abbr: ["ES"],
        name: "European Specification",
        harmonized_stages: %w[60.00 60.60],
      ),

      # CEN Report (CR)
      Pubid::Components::TypedStage.new(
        code: :pubcr,
        stage_code: :published,
        type_code: :cr,
        abbr: ["CR"],
        name: "CEN Report",
        harmonized_stages: %w[60.00 60.60],
      ),

      # European Prestandard (ENV)
      Pubid::Components::TypedStage.new(
        code: :pubenv,
        stage_code: :published,
        type_code: :env,
        abbr: ["ENV"],
        name: "European Prestandard",
        harmonized_stages: %w[60.00 60.60],
      ),
    ].freeze

    # Default typed stage for when no match is found
    DEFAULT_TYPED_STAGE = Pubid::Components::TypedStage.new(
      code: :puben,
      stage_code: :published,
      type_code: :en,
      abbr: ["EN"],
      name: "European Norm",
      harmonized_stages: %w[60.00 60.60],
    ).freeze

    def self.parse(identifier)
      if identifier.length > Pubid::MAX_INPUT_LENGTH
        raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
      end

      CenCenelec::Identifier.parse(identifier)
    end

    # Auto-discover all identifier types from the Identifiers namespace
    # @return [Array<Class>] identifier classes that define a self.type Hash
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c.singleton_methods(false).include?(:type) }
        .select { |c| c.type.is_a?(Hash) }
    end

    # Build typed stage index from the module's TYPED_STAGES_REGISTRY
    # @return [Array<Pubid::Components::TypedStage>] all typed stages
    def self.all_typed_stages
      TYPED_STAGES_REGISTRY
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

Pubid::Registry.register(:cen_cenelec, Pubid::CenCenelec)
Pubid::Registry.register(:cen, Pubid::CenCenelec)

# Per-flavor format registry: inherits global formats, overrides :human
# Register on both root hierarchies: SingleIdentifier and Identifiers::Base
cen_renderer = Pubid::CenCenelec::Renderer
Pubid::CenCenelec::SingleIdentifier.format_registry = Pubid::FormatRegistry.new(parent: Pubid::Identifier.format_registry)
Pubid::CenCenelec::SingleIdentifier.format_registry.register(:human, renderer: cen_renderer)
Pubid::CenCenelec::Identifiers::Base.format_registry = Pubid::FormatRegistry.new(parent: Pubid::Identifier.format_registry)
Pubid::CenCenelec::Identifiers::Base.format_registry.register(:human, renderer: cen_renderer)
