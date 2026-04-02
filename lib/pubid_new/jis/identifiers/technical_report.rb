# frozen_string_literal: true

require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Jis
    module Identifiers
      # Technical Report identifier type
      # Format: JIS TR SERIES NUMBER:YEAR
      # Example: JIS TR Z 8301:2019
      class TechnicalReport < SingleIdentifier
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :tr,
            stage_code: :published,
            type_code: :tr,
            abbr: ["TR"],
            name: "Technical Report",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :tr, title: "Technical Report", short: "TR" }
        end

        def type_prefix
          "TR"
        end
      end
    end
  end
end
