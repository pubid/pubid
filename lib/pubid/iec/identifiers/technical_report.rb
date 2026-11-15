# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Technical Report identifier class
      # Single Responsibility: Represents IEC Technical Report documents
      class TechnicalReport < Base
        # Convert v1 hash-based TYPED_STAGES to v2 object-based
        # From gems/pubid-iec/lib/pubid/iec/identifier/technical_report.rb
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pwi_tr,
            stage_code: :pwi,
            type_code: :tr,
            abbr: ["PWI TR"],
            name: "Preliminary Work Item Technical Report",
            harmonized_stages: %w[00.00 00.20 00.60 00.98 00.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :np_tr,
            stage_code: :np,
            type_code: :tr,
            abbr: ["NP TR"],
            name: "New Proposal Technical Report",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.98],
          ),
          Pubid::Components::TypedStage.new(
            code: :anw_tr,
            stage_code: :anw,
            type_code: :tr,
            abbr: ["ANW TR"],
            name: "Approved New Work Item Technical Report",
            harmonized_stages: %w[10.99 20.00],
          ),
          Pubid::Components::TypedStage.new(
            code: :wd_tr,
            stage_code: :wd,
            type_code: :tr,
            abbr: ["WD TR"],
            name: "Working Draft Technical Report",
            harmonized_stages: %w[20.20 20.60 20.98 20.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :cd_tr,
            stage_code: :cd,
            type_code: :tr,
            abbr: ["CD TR"],
            name: "Committee Draft Technical Report",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.98 30.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :dtr,
            stage_code: :draft,
            type_code: :tr,
            # Plain DTR keeps the folded 50.00 ladder (the registration
            # step). The point spellings below are rows of their own, each
            # with the exact code IEC's stage-code correspondence table
            # gives it (pubid#733).
            abbr: %w[DTR],
            name: "Draft Technical Report",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          # The TR ladder's point spellings, with the codes from IEC's
          # stage-code correspondence table (IEC/ISO Harmonized APIs,
          # section 3 "IEC/ISO Stage Code correspondance", identical in
          # v0.0.7 2021-05 and v0.0.8 2023-06; extracted at
          # data/iec/stage-codes.md). The per-spelling data was already in
          # PROJECT_STAGES below; wiring it into rows makes the official
          # URN's stage slot (harmonized_stages.first) carry the table's
          # code instead of folding every spelling onto 50.00 (pubid#733).
          # Row order follows the correspondence table; NDTR and DTRM
          # share 50.92 there, so their official-URN slot is the same and
          # the reverse lookup resolves the first row (DTRM).
          Pubid::Components::TypedStage.new(
            code: :adtr,
            stage_code: :draft,
            type_code: :tr,
            abbr: %w[ADTR],
            name: "Approved for DTR",
            harmonized_stages: %w[40.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :cdtr,
            stage_code: :draft,
            type_code: :tr,
            abbr: %w[CDTR],
            name: "Draft circulated as DTR",
            harmonized_stages: %w[50.20],
          ),
          Pubid::Components::TypedStage.new(
            code: :dtrm,
            stage_code: :draft,
            type_code: :tr,
            abbr: %w[DTRM],
            name: "Rejected DTR to be discussed at meeting",
            harmonized_stages: %w[50.92],
          ),
          Pubid::Components::TypedStage.new(
            code: :ndtr,
            stage_code: :draft,
            type_code: :tr,
            abbr: %w[NDTR],
            name: "DTR rejected",
            harmonized_stages: %w[50.92],
          ),
          Pubid::Components::TypedStage.new(
            code: :tr,
            stage_code: :published,
            type_code: :tr,
            abbr: ["TR"],
            name: "Technical Report",
            harmonized_stages: %w[60.00 60.60 90.20 90.60 90.92 90.93 90.99
                                  95.20 95.60 95.92 95.99],
          ),
        ].freeze

        # Project stages specific to Technical Reports
        # These are IEC-specific workflow stages
        PROJECT_STAGES = {
          adtr: {
            abbr: "ADTR",
            name: "Approved for DTR",
            harmonized_stages: %w[40.99],
          },
          cdtr: {
            abbr: "CDTR",
            name: "Draft circulated as DTR",
            harmonized_stages: %w[50.20],
          },
          dtrm: {
            abbr: "DTRM",
            name: "Rejected DTR to be discussed at meeting",
            harmonized_stages: %w[50.92],
          },
          ndtr: {
            abbr: "NDTR",
            name: "DTR rejected",
            harmonized_stages: %w[50.92],
          },
          prvdtr: {
            abbr: "PRVDTR",
            name: "Preparation of RVDTR",
            harmonized_stages: %w[50.60],
          },
          tdtr: {
            abbr: "TDTR",
            name: "Translation of DTR",
            harmonized_stages: %w[50.00],
          },
        }.freeze

        def self.type
          { key: :tr,
            web: :technical_report, title: "Technical Report", short: "TR" }
        end

      end
    end
  end
end
