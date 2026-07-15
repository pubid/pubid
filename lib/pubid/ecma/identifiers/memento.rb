# frozen_string_literal: true

module Pubid
  module Ecma
    module Identifiers
      # Memento identifier type.
      # Format: ECMA MEM/<year>. Example: ECMA MEM/1970
      class Memento < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :mem,
            stage_code: :published,
            type_code: :ecma,
            abbr: ["MEM"],
            name: "Memento",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :mem, web: :memento, title: "Memento", short: "MEM" }
        end

        def type_prefix
          "MEM"
        end
      end
    end
  end
end
