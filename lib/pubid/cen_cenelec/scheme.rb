# frozen_string_literal: true

module Pubid
  module CenCenelec
    class Scheme
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

      # Map type codes to identifier classes
      IDENTIFIER_CLASS_MAP = {
        en: "Identifiers::EuropeanNorm",
        ts: "Identifiers::TechnicalSpecification",
        tr: "Identifiers::TechnicalReport",
        cwa: "Identifiers::CenWorkshopAgreement",
        guide: "Identifiers::Guide",
        hd: "Identifiers::HarmonizationDocument",
        es: "Identifiers::EuropeanSpecification",
        cr: "Identifiers::CenReport",
        env: "Identifiers::EuropeanPrestandard",
      }.freeze

      # Default typed stage for when no match is found
      DEFAULT_TYPED_STAGE = Pubid::Components::TypedStage.new(
        code: :puben,
        stage_code: :published,
        type_code: :en,
        abbr: ["EN"],
        name: "European Norm",
        harmonized_stages: %w[60.00 60.60],
      ).freeze

      def locate_typed_stage_by_abbr(abbr)
        abbr_str = abbr.to_s.strip
        TYPED_STAGES_REGISTRY.find do |ts|
          ts.abbr.include?(abbr_str)
        end || DEFAULT_TYPED_STAGE
      end

      def locate_identifier_klass_by_type_code(type_code)
        class_name = IDENTIFIER_CLASS_MAP[type_code.to_sym]
        return Identifiers::EuropeanNorm unless class_name

        # Convert string to actual class
        class_name.split("::").reduce(Pubid::CenCenelec) do |mod, name|
          mod.const_get(name)
        end
      end
    end
  end
end
