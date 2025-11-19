require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Iec
    module Identifiers
      # International Standard identifier class
      # Single Responsibility: Represents IEC International Standard documents
      class InternationalStandard < Base
        # International Standards need a TypedStage with empty abbr for published standards
        # From gems/pubid-iec/lib/pubid/iec/identifier/international_standard.rb
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :is,
            stage_code: :published,
            type_code: :is,
            abbr: [""],
            name: "International Standard",
            harmonized_stages: %w[60.00 60.60]
          )
        ].freeze

        # Project stages specific to International Standards
        # These are IEC-specific workflow stages
        PROJECT_STAGES = {
          afdis: {
            abbr: "AFDIS",
            name: "Approved for FDIS",
            harmonized_stages: %w[40.99]
          },
          ccdv: {
            abbr: "CCDV",
            name: "Draft circulated as CDV",
            harmonized_stages: %w[40.20]
          },
          cdvm: {
            abbr: "CDVM",
            name: "Rejected CDV to be discussed at a meeting",
            harmonized_stages: %w[40.91]
          },
          cfdis: {
            abbr: "CFDIS",
            name: "Draft circulated as FDIS",
            harmonized_stages: %w[50.20]
          },
          decfdis: {
            abbr: "DECFDIS",
            name: "FDIS at editing check",
            harmonized_stages: %w[50.00]
          },
          ncdv: {
            abbr: "NCDV",
            name: "CDV rejected",
            harmonized_stages: %w[40.91]
          },
          nfdis: {
            abbr: "NFDIS",
            name: "FDIS rejected",
            harmonized_stages: %w[50.92]
          },
          prvc: {
            abbr: "PRVC",
            name: "Preparation of RVC",
            harmonized_stages: %w[40.60]
          },
          prvd: {
            abbr: "PRVD",
            name: "Preparation of RVD",
            harmonized_stages: %w[50.60]
          },
          rfdis: {
            abbr: "RFDIS",
            name: "FDIS received and registered",
            harmonized_stages: %w[50.00]
          },
          tcdv: {
            abbr: "TCDV",
            name: "Translation of CDV",
            harmonized_stages: %w[40.00]
          }
        }.freeze

        def self.type
          { key: :is, title: "International Standard", short: nil }
        end
      end
    end
  end
end