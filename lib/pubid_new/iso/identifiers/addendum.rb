require_relative "../supplement_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
  module Identifiers
    class Addendum < SupplementIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :dad,
          stage_code: :dad,
          type_code: :add,
          abbr: ["DAD"],
          name: "Draft Addendum",
          harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
        ),
        Components::TypedStage.new(
          code: :fdad,
          stage_code: :fdad,
          type_code: :add,
          abbr: ["FDAD"],
          name: "Final Draft Addendum",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :pubadd,
          stage_code: :published,
          type_code: :add,
          abbr: ["Add", "ADD", "Addendum", "Add."],
          name: "Addendum",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :add, title: "Addendum", short: "ADD" }
      end
    end
  end
end
end