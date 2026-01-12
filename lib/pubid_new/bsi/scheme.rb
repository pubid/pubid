# frozen_string_literal: true

require_relative "../components/typed_stage"
require_relative "../components/stage"
require_relative "../components/type"

module PubidNew
  module Bsi
    class Scheme
      # TYPED_STAGES_REGISTRY for native BSI types
      TYPED_STAGES_REGISTRY = [
        # British Standard (BS)
        PubidNew::Components::TypedStage.new(
          code: :pubbs,
          stage_code: :published,
          type_code: :bs,
          abbr: ["BS"],
          name: "British Standard",
          harmonized_stages: %w[60.00 60.60],
        ),
        PubidNew::Components::TypedStage.new(
          code: :drbs,
          stage_code: :draft,
          type_code: :bs,
          abbr: ["Draft BS", "DBS"],
          name: "Draft British Standard",
          harmonized_stages: %w[30.00 30.20 30.60 40.00 40.20 40.60],
        ),

        # Published Document (PD)
        PubidNew::Components::TypedStage.new(
          code: :pubpd,
          stage_code: :published,
          type_code: :pd,
          abbr: ["PD"],
          name: "Published Document",
          harmonized_stages: %w[60.00 60.60],
        ),

        # Publicly Available Specification (PAS)
        PubidNew::Components::TypedStage.new(
          code: :pubpas,
          stage_code: :published,
          type_code: :pas,
          abbr: ["PAS"],
          name: "Publicly Available Specification",
          harmonized_stages: %w[60.00 60.60],
        ),

        # National Annex (NA)
        PubidNew::Components::TypedStage.new(
          code: :pubna,
          stage_code: :published,
          type_code: :na,
          abbr: ["NA"],
          name: "National Annex",
          harmonized_stages: %w[60.00 60.60],
        ),

        # Draft Document (DD)
        PubidNew::Components::TypedStage.new(
          code: :pubdd,
          stage_code: :published,
          type_code: :dd,
          abbr: ["DD"],
          name: "Draft Document",
          harmonized_stages: %w[60.00 60.60],
        ),

        # Flex Document
        PubidNew::Components::TypedStage.new(
          code: :pubflex,
          stage_code: :published,
          type_code: :flex,
          abbr: ["Flex", "BSI Flex"],
          name: "BSI Flex",
          harmonized_stages: %w[60.00 60.60],
        ),

        # Handbook
        PubidNew::Components::TypedStage.new(
          code: :pubhandbook,
          stage_code: :published,
          type_code: :handbook,
          abbr: ["Handbook", "HB"],
          name: "BSI Handbook",
          harmonized_stages: %w[60.00 60.60],
        ),

        # Practice Guide (PP)
        PubidNew::Components::TypedStage.new(
          code: :pubpp,
          stage_code: :published,
          type_code: :pp,
          abbr: ["PP"],
          name: "Published Practice",
          harmonized_stages: %w[60.00 60.60],
        ),

        # British Industrial Practice (BIP)
        PubidNew::Components::TypedStage.new(
          code: :pubbip,
          stage_code: :published,
          type_code: :bip,
          abbr: ["BIP"],
          name: "British Industrial Practice",
          harmonized_stages: %w[60.00 60.60],
        ),

        # Aerospace/Specialized British Standard (with letter prefix)
        PubidNew::Components::TypedStage.new(
          code: :pubaerospace,
          stage_code: :published,
          type_code: :aerospace,
          abbr: ["BS A", "BS AU", "BS C", "BS M", "BS S", "BS L", "BS TA", "BS MA", "BS PL", "BS QC", "BS G", "BS HC", "BS F", "BS X", "BS B"],
          name: "Aerospace/Specialized British Standard",
          harmonized_stages: %w[60.00 60.60],
        ),

        # Index
        PubidNew::Components::TypedStage.new(
          code: :pubindex,
          stage_code: :published,
          type_code: :index,
          abbr: ["Index"],
          name: "BSI Index",
          harmonized_stages: %w[60.00 60.60],
        ),

        # Method
        PubidNew::Components::TypedStage.new(
          code: :pubmethod,
          stage_code: :published,
          type_code: :method,
          abbr: ["Method", "Methods"],
          name: "BSI Method",
          harmonized_stages: %w[60.00 60.60],
        ),

        # Section
        PubidNew::Components::TypedStage.new(
          code: :pubsection,
          stage_code: :published,
          type_code: :section,
          abbr: ["Section"],
          name: "BSI Section",
          harmonized_stages: %w[60.00 60.60],
        ),

        # DISC (Delivering Information Solutions to Customers)
        PubidNew::Components::TypedStage.new(
          code: :pubdisc,
          stage_code: :published,
          type_code: :disc,
          abbr: ["DISC"],
          name: "DISC",
          harmonized_stages: %w[60.00 60.60],
        ),

        # Detailed Specification (with N or C notation)
        PubidNew::Components::TypedStage.new(
          code: :pubdetailed_spec,
          stage_code: :published,
          type_code: :detailed_specification,
          abbr: ["DETAILED SPEC"],
          name: "Detailed Specification",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      # Map type codes to identifier classes
      IDENTIFIER_CLASS_MAP = {
        bs: "Identifiers::BritishStandard",
        pd: "Identifiers::PublishedDocument",
        pas: "Identifiers::PubliclyAvailableSpecification",
        na: "Identifiers::NationalAnnex",
        dd: "Identifiers::DraftDocument",
        flex: "Identifiers::Flex",
        handbook: "Identifiers::Handbook",
        pp: "Identifiers::PracticeGuide",
        bip: "Identifiers::BritishIndustrialPractice",
        aerospace: "Identifiers::AerospaceStandard",
        index: "Identifiers::Index",
        method: "Identifiers::Method",
        section: "Identifiers::Section",
        disc: "Identifiers::Disc",
        bundled: "Identifiers::BundledIdentifier",
        detailed_specification: "Identifiers::DetailedSpecification",
      }.freeze

      # Default typed stage for when no match is found
      DEFAULT_TYPED_STAGE = PubidNew::Components::TypedStage.new(
        code: :pubbs,
        stage_code: :published,
        type_code: :bs,
        abbr: ["BS"],
        name: "British Standard",
        harmonized_stages: %w[60.00 60.60],
      ).freeze

      def locate_typed_stage_by_abbr(abbr)
        abbr_str = abbr.to_s.strip
        TYPED_STAGES_REGISTRY.find { |ts| ts.abbr.include?(abbr_str) } || DEFAULT_TYPED_STAGE
      end

      def locate_identifier_klass_by_type_code(type_code)
        class_name = IDENTIFIER_CLASS_MAP[type_code.to_sym]
        return Identifiers::BritishStandard unless class_name

        # Convert string to actual class
        class_name.split("::").reduce(PubidNew::Bsi) { |mod, name| mod.const_get(name) }
      end
    end
  end
end