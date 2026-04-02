# frozen_string_literal: true

module Pubid
  module Jcgm
    module Identifiers
      class Guide < SingleIdentifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: [""],
            type_code: :guide,
            stage_code: :published,
          ),
        ].freeze

        def self.type
          { key: :guide, title: "Guide" }
        end
      end
    end
  end
end
