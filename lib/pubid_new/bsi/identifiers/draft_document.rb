# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # Draft Document (DD) identifier
      class DraftDocument < SingleIdentifier
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :pubdd,
            stage_code: :published,
            type_code: :dd,
            abbr: ["DD"],
            name: "Draft Document",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :dd, title: "Draft Document", short: "DD" }
        end
      end
    end
  end
end
