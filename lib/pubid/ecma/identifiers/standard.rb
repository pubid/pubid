# frozen_string_literal: true

module Pubid
  module Ecma
    module Identifiers
      # Default ECMA identifier type (no type token).
      # Examples: ECMA-411, ECMA-418-1
      class Standard < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :standard,
            stage_code: :published,
            type_code: :ecma,
            abbr: ["ECMA"],
            name: "Standard",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :standard, web: :standard, title: "Standard", short: "ECMA" }
        end

        # No type token for standards.
        def type_prefix
          nil
        end
      end
    end
  end
end
