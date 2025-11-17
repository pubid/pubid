require "lutaml/model"
require_relative "../single_identifier"

module PubidNew
  module Jis
    module Identifiers
      class Standard < SingleIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubjis,
            stage_code: :published,
            type_code: :jis,
            abbr: ["JIS"],
            name: "Japanese Industrial Standard",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :jis, title: "Japanese Industrial Standard", short: "JIS" }
        end
      end
    end
  end
end