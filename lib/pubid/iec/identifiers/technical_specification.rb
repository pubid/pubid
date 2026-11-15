# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Technical Specification identifier class
      # Single Responsibility: Represents IEC Technical Specification documents
      class TechnicalSpecification < Base
        # Convert v1 hash-based TYPED_STAGES to v2 object-based
        # From gems/pubid-iec/lib/pubid/iec/identifier/technical_specification.rb
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pwi_ts,
            stage_code: :pwi,
            type_code: :ts,
            abbr: ["PWI TS"],
            name: "Preliminary Work Item Technical Specification",
            harmonized_stages: %w[00.00 00.20 00.60 00.98 00.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :np_ts,
            stage_code: :np,
            type_code: :ts,
            abbr: ["NP TS"],
            name: "New Proposal Technical Specification",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.98],
          ),
          Pubid::Components::TypedStage.new(
            code: :anw_ts,
            stage_code: :anw,
            type_code: :ts,
            abbr: ["ANW TS"],
            name: "Approved New Work Item Technical Specification",
            harmonized_stages: %w[10.99 20.00],
          ),
          Pubid::Components::TypedStage.new(
            code: :wd_ts,
            stage_code: :wd,
            type_code: :ts,
            abbr: ["WD TS"],
            name: "Working Draft Technical Specification",
            harmonized_stages: %w[20.20 20.60 20.98 20.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :cd_ts,
            stage_code: :cd,
            type_code: :ts,
            abbr: ["CD TS"],
            name: "Committee Draft Technical Specification",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.98 30.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :dts,
            stage_code: :draft,
            type_code: :ts,
            # Plain DTS keeps the folded 50.00 ladder (the registration
            # step). The point spellings below are rows of their own, each
            # with the exact code IEC's stage-code correspondence table
            # gives it (pubid#733).
            abbr: %w[DTS],
            name: "Draft Technical Specification",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          # The TS ladder's point spellings, with the codes from IEC's
          # stage-code correspondence table (IEC/ISO Harmonized APIs,
          # section 3 "IEC/ISO Stage Code correspondance", identical in
          # v0.0.7 2021-05 and v0.0.8 2023-06; extracted at
          # data/iec/stage-codes.md). The per-spelling data was already in
          # PROJECT_STAGES below; wiring it into rows makes the official
          # URN's stage slot (harmonized_stages.first) carry the table's
          # code instead of folding every spelling onto 50.00 (pubid#733).
          # Row order follows the correspondence table; NDTS and DTSM
          # share 50.92 there, so their official-URN slot is the same and
          # the reverse lookup resolves the first row (DTSM).
          Pubid::Components::TypedStage.new(
            code: :adts,
            stage_code: :draft,
            type_code: :ts,
            abbr: %w[ADTS],
            name: "Approved for DTS",
            harmonized_stages: %w[40.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :cdts,
            stage_code: :draft,
            type_code: :ts,
            abbr: %w[CDTS],
            name: "Draft circulated as DTS",
            harmonized_stages: %w[50.20],
          ),
          Pubid::Components::TypedStage.new(
            code: :dtsm,
            stage_code: :draft,
            type_code: :ts,
            abbr: %w[DTSM],
            name: "Rejected DTS to be discussed at meeting",
            harmonized_stages: %w[50.92],
          ),
          Pubid::Components::TypedStage.new(
            code: :ndts,
            stage_code: :draft,
            type_code: :ts,
            abbr: %w[NDTS],
            name: "DTS rejected",
            harmonized_stages: %w[50.92],
          ),
          Pubid::Components::TypedStage.new(
            code: :ts,
            stage_code: :published,
            type_code: :ts,
            abbr: ["TS"],
            name: "Technical Specification",
            harmonized_stages: %w[60.00 60.60 90.20 90.60 90.92 90.93 90.99
                                  95.20 95.60 95.92 95.99],
          ),
        ].freeze

        # Project stages specific to Technical Specifications
        # These are IEC-specific workflow stages
        PROJECT_STAGES = {
          adts: {
            abbr: "ADTS",
            name: "Approved for DTS",
            harmonized_stages: %w[40.99],
          },
          cdts: {
            abbr: "CDTS",
            name: "Draft circulated as DTS",
            harmonized_stages: %w[50.20],
          },
          dtsm: {
            abbr: "DTSM",
            name: "Rejected DTS to be discussed at meeting",
            harmonized_stages: %w[50.92],
          },
          ndts: {
            abbr: "NDTS",
            name: "DTS rejected",
            harmonized_stages: %w[50.92],
          },
          prvdts: {
            abbr: "PRVDTS",
            name: "Preparation of RVDTS",
            harmonized_stages: %w[50.60],
          },
          tdts: {
            abbr: "TDTS",
            name: "Translation of DTS",
            harmonized_stages: %w[50.00],
          },
        }.freeze

        def self.type
          { key: :ts,
            web: :technical_specification, title: "Technical Specification", short: "TS" }
        end

      end
    end
  end
end
