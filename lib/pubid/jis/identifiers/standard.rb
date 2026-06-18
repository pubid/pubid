# frozen_string_literal: true

module Pubid
  module Jis
    module Identifiers
      class Standard < SingleIdentifier
        # Note: type is handled through TYPED_STAGES, not as a separate attribute
        # The Components::Type dependency was removed as it doesn't exist

        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubjis,
            stage_code: :published,
            type_code: :jis,
            abbr: ["JIS"],
            name: "Japanese Industrial Standard",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :jis,
            web: :japanese_industrial_standard, title: "Japanese Industrial Standard", short: "JIS" }
        end
      end
    end
  end
end
