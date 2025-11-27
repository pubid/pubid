require_relative "../supplement_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
  module Identifiers
    class Supplement < SupplementIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :npsuppl,
          stage_code: :np,
          type_code: :suppl,
          abbr: ["NP Suppl"],
          name: "New Work Item Proposal for Supplement",
          harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
        ),
        Components::TypedStage.new(
          code: :awisuppl,
          stage_code: :awi,
          type_code: :suppl,
          abbr: ["AWI Suppl"],
          name: "Approved Work Item for Supplement",
          harmonized_stages: %w[10.99 20.00],
        ),
        Components::TypedStage.new(
          code: :wdsuppl,
          stage_code: :wd,
          type_code: :suppl,
          abbr: ["WD Suppl"],
          name: "Working Draft for Supplement",
          harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
        ),
        Components::TypedStage.new(
          code: :cdsuppl,
          stage_code: :cd,
          type_code: :suppl,
          abbr: ["CD Suppl"],
          name: "Committee Draft for Supplement",
          harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
        ),
        Components::TypedStage.new(
          code: :dsuppl,
          stage_code: :dsuppl,
          type_code: :suppl,
          abbr: ["DSuppl"],
          name: "Draft Supplement",
          harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
        ),
        Components::TypedStage.new(
          code: :fdsuppl,
          stage_code: :fdsuppl,
          type_code: :suppl,
          abbr: ["FDSuppl", "FDIS Suppl"],
          name: "Final Draft Supplement",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :prfsuppl,
          stage_code: :prf,
          type_code: :suppl,
          abbr: ["PRF Suppl"],
          name: "Proof Supplement",
          harmonized_stages: %w[60.00],
        ),
        Components::TypedStage.new(
          code: :pubsuppl,
          stage_code: :published,
          type_code: :suppl,
          abbr: ["Suppl", "Suppl."],
          name: "Supplement",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      # Override URN type code - Supplement uses 'sup' in URN (RFC 5141)
      def urn_supplement_type
        "sup"
      end

      def self.type
        { key: :suppl, title: "Supplement", short: "suppl" }
      end
    end
  end
end
end