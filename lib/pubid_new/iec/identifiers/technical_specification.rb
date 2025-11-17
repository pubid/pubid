require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iec
  module Identifiers
    # Technical Specification Identifier
    class TechnicalSpecification < SingleIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :dts,
          stage_code: :dts,
          type_code: :ts,
          abbr: ["DTS"],
          name: "Draft Technical Specification",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :ts,
          stage_code: :published,
          type_code: :ts,
          abbr: ["TS"],
          name: "Technical Specification",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :ts, title: "Technical Specification", short: "TS" }
      end
    end
  end
end
end