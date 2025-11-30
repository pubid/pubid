# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # Published Document (PD) identifier
      class PublishedDocument < SingleIdentifier
        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubpd,
            stage_code: :published,
            type_code: :pd,
            abbr: ["PD"],
            name: "Published Document",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :pd, title: "Published Document", short: "PD" }
        end
      end
    end
  end
end