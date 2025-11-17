require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iec
  module Identifiers
    # Publicly Available Specification Identifier
    class PubliclyAvailableSpecification < SingleIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :dpas,
          stage_code: :dpas,
          type_code: :pas,
          abbr: ["DPAS"],
          name: "Draft Publicly Available Specification",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :pas,
          stage_code: :published,
          type_code: :pas,
          abbr: ["PAS"],
          name: "Publicly Available Specification",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :pas, title: "Publicly Available Specification", short: "PAS" }
      end
    end
  end
end
end