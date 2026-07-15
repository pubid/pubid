# frozen_string_literal: true

module Pubid
  module Calconnect
    module Identifiers
      # The sole CalConnect document type. Its polymorphic_name resolves
      # automatically to "pubid:calconnect:standard".
      class Standard < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubcc,
            stage_code: :published,
            type_code: :cc,
            abbr: ["CC"],
            name: "CalConnect Standard",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :cc,
            web: :standard,
            title: "CalConnect Standard",
            short: "CC" }
        end
      end
    end
  end
end
