# frozen_string_literal: true

module Pubid
  module W3c
    module Identifiers
      # W3C Note (formerly Working Group / Interest Group Note).
      # Printed token: "NOTE". Example: "W3C NOTE-xml-names".
      class Note < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :note,
            stage_code: :note,
            type_code: :note,
            abbr: ["NOTE"],
            name: "W3C Note",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :note, web: :note, title: "W3C Note", short: "NOTE" }
        end

        def type_prefix
          "NOTE"
        end
      end
    end
  end
end
