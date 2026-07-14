# frozen_string_literal: true

module Pubid
  module W3c
    module Identifiers
      # Draft W3C Note. Printed token: "DNOTE".
      # Example: "W3C DNOTE-webcodecs-flac-codec-registration-20240419".
      class DraftNote < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :dnote,
            stage_code: :draft_note,
            type_code: :dnote,
            abbr: ["DNOTE"],
            name: "Draft W3C Note",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :dnote, web: :draft_note, title: "Draft W3C Note",
            short: "DNOTE" }
        end

        def type_prefix
          "DNOTE"
        end
      end
    end
  end
end
