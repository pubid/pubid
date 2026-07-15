# frozen_string_literal: true

module Pubid
  module Ecma
    module Identifiers
      # Technical Report identifier type.
      # Format: ECMA TR/<number>. Example: ECMA TR/101
      class TechnicalReport < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :tr,
            stage_code: :published,
            type_code: :ecma,
            abbr: ["TR"],
            name: "Technical Report",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :tr, web: :technical_report, title: "Technical Report",
            short: "TR" }
        end

        def type_prefix
          "TR"
        end
      end
    end
  end
end
