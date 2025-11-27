require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
  module Identifiers
    class Recommendation < SingleIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :dp,
          stage_code: :np,
          type_code: :rec,
          abbr: ["DP"],
          name: "Draft Proposal",
          harmonized_stages: %w[
            00.00 00.20 00.60 00.92 00.93 00.98 00.99
            10.00 10.20 10.60 10.92 10.93 10.98 10.99
            20.00 20.20 20.60 20.92 20.93 20.98 20.99
            30.00 30.20 30.60 30.92 30.93 30.98 30.99
            40.00 40.20 40.60 40.92 40.93 40.98 40.99
          ],
        ),
        Components::TypedStage.new(
          code: :rec,
          stage_code: :published,
          type_code: :rec,
          abbr: ["R"],
          name: "Recommendation",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :rec, title: "Recommendation", short: "R" }
      end

      # Override URN type code - Recommendation uses 'r' in URN (RFC 5141)
      def urn_type_code
        "r"
      end
    end
  end
end
end
