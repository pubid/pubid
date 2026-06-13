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
    autoload :SingleIdentifier, "#{__dir__}/bsi/single_identifier"
    autoload :UrnGenerator, "#{__dir__}/bsi/urn_generator"

    # TYPED_STAGES_REGISTRY for native BSI types. Used by Pubid::Bsi.locate_stage
    # to map abbreviations (e.g. "BS", "PD", "Handbook") to typed stages.
    TYPED_STAGES_REGISTRY = [
      # British Standard (BS)
      Pubid::Components::TypedStage.new(
        code: :pubbs,
        stage_code: :published,
        type_code: :bs,
        abbr: ["BS"],
        name: "British Standard",
        harmonized_stages: %w[60.00 60.60],
      ),
      Pubid::Components::TypedStage.new(
        code: :drbs,
        stage_code: :draft,
        type_code: :bs,
        abbr: ["Draft BS", "DBS"],
        name: "Draft British Standard",
        harmonized_stages: %w[30.00 30.20 30.60 40.00 40.20 40.60],
      ),

      # Published Document (PD)
      Pubid::Components::TypedStage.new(
        code: :pubpd,
        stage_code: :published,
        type_code: :pd,
        abbr: ["PD"],
        name: "Published Document",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Publicly Available Specification (PAS)
      Pubid::Components::TypedStage.new(
        code: :pubpas,
        stage_code: :published,
        type_code: :pas,
        abbr: ["PAS"],
        name: "Publicly Available Specification",
        harmonized_stages: %w[60.00 60.60],
      ),

      # National Annex (NA)
      Pubid::Components::TypedStage.new(
        code: :pubna,
        stage_code: :published,
        type_code: :na,
        abbr: ["NA"],
        name: "National Annex",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Draft Document (DD)
      Pubid::Components::TypedStage.new(
        code: :pubdd,
        stage_code: :published,
        type_code: :dd,
        abbr: ["DD"],
        name: "Draft Document",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Flex Document
      Pubid::Components::TypedStage.new(
        code: :pubflex,
        stage_code: :published,
        type_code: :flex,
        abbr: ["Flex", "BSI Flex"],
        name: "BSI Flex",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Handbook
      Pubid::Components::TypedStage.new(
        code: :pubhandbook,
        stage_code: :published,
        type_code: :handbook,
        abbr: ["Handbook", "HB"],
        name: "BSI Handbook",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Practice Guide (PP)
      Pubid::Components::TypedStage.new(
        code: :pubpp,
        stage_code: :published,
        type_code: :pp,
        abbr: ["PP"],
        name: "Published Practice",
        harmonized_stages: %w[60.00 60.60],
      ),

      # British Industrial Practice (BIP)
      Pubid::Components::TypedStage.new(
        code: :pubbip,
        stage_code: :published,
        type_code: :bip,
        abbr: ["BIP"],
        name: "British Industrial Practice",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Aerospace/Specialized British Standard (with letter prefix)
      Pubid::Components::TypedStage.new(
        code: :pubaerospace,
        stage_code: :published,
        type_code: :aerospace,
        abbr: ["BS A", "BS AU", "BS C", "BS M", "BS S", "BS L", "BS TA",
               "BS MA", "BS PL", "BS QC", "BS G", "BS HC", "BS F", "BS X", "BS B"],
        name: "Aerospace/Specialized British Standard",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Index
      Pubid::Components::TypedStage.new(
        code: :pubindex,
        stage_code: :published,
        type_code: :index,
        abbr: ["Index"],
        name: "BSI Index",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Method
      Pubid::Components::TypedStage.new(
        code: :pubmethod,
        stage_code: :published,
        type_code: :method,
        abbr: ["Method", "Methods"],
        name: "BSI Method",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Section
      Pubid::Components::TypedStage.new(
        code: :pubsection,
        stage_code: :published,
        type_code: :section,
        abbr: ["Section"],
        name: "BSI Section",
        harmonized_stages: %w[60.00 60.60],
      ),

      # DISC (Delivering Information Solutions to Customers)
      Pubid::Components::TypedStage.new(
        code: :pubdisc,
        stage_code: :published,
        type_code: :disc,
        abbr: ["DISC"],
        name: "DISC",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Detailed Specification (with N or C notation)
      Pubid::Components::TypedStage.new(
        code: :pubdetailed_spec,
        stage_code: :published,
        type_code: :detailed_specification,
        abbr: ["DETAILED SPEC"],
        name: "Detailed Specification",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Standalone Amendment
      Pubid::Components::TypedStage.new(
        code: :standalone_amendment,
        stage_code: :published,
        type_code: :amendment,
        abbr: ["AMD"],
        name: "Amendment",
        harmonized_stages: %w[60.00 60.60],
      ),

      # Technical Specification
      Pubid::Components::TypedStage.new(
        code: :pubts,
        stage_code: :published,
        type_code: :ts,
        abbr: ["TS"],
        name: "Technical Specification",
        harmonized_stages: %w[60.00 60.60],
      ),
    ].freeze

    def self.parse(string)
      Identifier.parse(string)
    end

    def self.transform(data)
      Builder.build(data)
    end

    # Auto-discover all identifier types from the Identifiers namespace.
    # Includes classes with explicit type declarations (Hash or nil).
    # @return [Array<Class>] identifier classes (Pubid::Identifier subclasses)
    def self.identifier_types
      @identifier_types ||= Identifiers.constants
        .filter_map { |c| begin; Identifiers.const_get(c); rescue NameError; nil; end }
        .select { |c| c.is_a?(Class) && c < Pubid::Identifier }
        .select { |c| c.singleton_methods(false).include?(:type) }
        .reject { |c| c.name&.split("::")&.last == "Base" }
    end

    # Build typed stage index from the module's TYPED_STAGES_REGISTRY
    # @return [Array<Pubid::Components::TypedStage>] all typed stages
    def self.all_typed_stages
      @all_typed_stages ||= TYPED_STAGES_REGISTRY
    end

    # Lookup: type code -> identifier class
    # @param code [String, Symbol] the type key to find
    # @return [Class, nil] the matching identifier class
    def self.locate_type(code)
      identifier_types.find { |t| t.type&.dig(:key)&.to_s == code.to_s }
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
