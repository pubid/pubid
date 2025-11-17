require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iec
  module Identifiers
    # Technical Report Identifier
    class TechnicalReport < SingleIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :dtr,
          stage_code: :dtr,
          type_code: :tr,
          abbr: ["DTR"],
          name: "Draft Technical Report",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :tr,
          stage_code: :published,
          type_code: :tr,
          abbr: ["TR"],
          name: "Technical Report",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :tr, title: "Technical Report", short: "TR" }
      end
    end
  end
end
end