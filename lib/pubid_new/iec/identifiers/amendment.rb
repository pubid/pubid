require_relative "../supplement_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iec
  module Identifiers
    # Amendment Identifier
    class Amendment < SupplementIdentifier
      attribute :type, PubidNew::Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        PubidNew::Components::TypedStage.new(
          code: :cdamd,
          stage_code: :cd,
          type_code: :amd,
          abbr: ["CDAM"],
          short_abbr: "CDV",
          long_abbr: "CD",
          name: "Committee Draft Amendment",
          harmonized_stages: %w[30.00 30.20 30.60 30.92 30.98 30.99],
        ),
        PubidNew::Components::TypedStage.new(
          code: :damd,
          stage_code: :damd,
          type_code: :amd,
          abbr: ["DAM"],
          short_abbr: "DAM",
          long_abbr: "DAm",
          name: "Draft Amendment",
          harmonized_stages: %w[40.00 40.20 40.60 40.92 40.98 40.99],
        ),
        PubidNew::Components::TypedStage.new(
          code: :fdamd,
          stage_code: :fdamd,
          type_code: :amd,
          abbr: ["FDAM"],
          short_abbr: "FDIS",
          long_abbr: "FDIS",
          name: "Final Draft Amendment",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        PubidNew::Components::TypedStage.new(
          code: :pubamd,
          stage_code: :published,
          type_code: :amd,
          abbr: ["Amd", "AMD"],
          short_abbr: "AMD",
          long_abbr: "Amd",
          name: "Amendment",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :amd, title: "Amendment", short: "AMD" }
      end
    end
  end
end
end