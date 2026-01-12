require "lutaml/model"
require_relative "../single_identifier"

module PubidNew
  module Cen
    module Identifiers
      class Guide < SingleIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubguide,
            stage_code: :published,
            type_code: :guide,
            abbr: ["Guide"],
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
