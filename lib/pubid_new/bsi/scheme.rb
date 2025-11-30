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
      ].freeze

      # Map type codes to identifier classes
      IDENTIFIER_CLASS_MAP = {
        bs: "Identifiers::BritishStandard",
        pd: "Identifiers::PublishedDocument",
        pas: "Identifiers::PubliclyAvailableSpecification",
        na: "Identifiers::NationalAnnex",
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