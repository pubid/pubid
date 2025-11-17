require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iec
  module Identifiers
    # Guide Identifier
    class Guide < SingleIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :dguide,
          stage_code: :dguide,
          type_code: :guide,
          abbr: ["DGuide"],
          name: "Draft Guide",
          harmonized_stages: %w[40.00 40.20 40.60 40.92 40.98 40.99],
        ),
        Components::TypedStage.new(
          code: :fdguide,
          stage_code: :fdguide,
          type_code: :guide,
          abbr: ["FDGuide"],
          name: "Final Draft Guide",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :guide,
          stage_code: :published,
          type_code: :guide,
          abbr: ["Guide", "GUIDE"],
          name: "Guide",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :guide, title: "Guide", short: "Guide" }
      end
    end
  end
end
end