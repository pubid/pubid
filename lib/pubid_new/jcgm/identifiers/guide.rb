# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Jcgm
    module Identifiers
      class Guide < SingleIdentifier
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            abbr: [""],
            type_code: :guide,
            stage_code: :published
          ),
        ].freeze

        def self.type
          { key: :guide, title: "Guide" }
        end
      end
    end
  end
end