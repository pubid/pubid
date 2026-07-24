# frozen_string_literal: true

module Pubid
  module Un
    module Identifiers
      class Document < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubun,
            stage_code: :published,
            type_code: :un,
            abbr: ["UN"],
            name: "UN Document",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :un, web: :document, title: "UN Document", short: "UN" }
        end
      end
    end
  end
end
