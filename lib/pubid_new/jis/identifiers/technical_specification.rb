# frozen_string_literal: true

require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Jis
    module Identifiers
      # Technical Specification identifier type
      # Format: JIS TS SERIES NUMBER:YEAR
      # Example: JIS TS Z 0030-1:2017
      class TechnicalSpecification < SingleIdentifier
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :ts,
            stage_code: :published,
            type_code: :ts,
            abbr: ["TS"],
            name: "Technical Specification",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :ts, title: "Technical Specification", short: "TS" }
        end

        def type_prefix
          "TS"
        end
      end
    end
  end
end
