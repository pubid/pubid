# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # British Standard (BS) identifier
      class BritishStandard < SingleIdentifier
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :pubbs,
            stage_code: :published,
            type_code: :bs,
            abbr: ["BS"],
            name: "British Standard",
            harmonized_stages: %w[60.00 60.60],
          ),
          PubidNew::Components::TypedStage.new(
            code: :drbs,
            stage_code: :draft,
            type_code: :bs,
            abbr: ["Draft BS", "DBS"],
            name: "Draft British Standard",
            harmonized_stages: %w[30.00 30.20 30.60 40.00 40.20 40.60],
          ),
        ].freeze

        def self.type
          { key: :bs, title: "British Standard", short: "BS" }
        end
      end
    end
  end
end
