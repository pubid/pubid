# frozen_string_literal: true

module Pubid
  module W3c
    module Identifiers
      # W3C Working Draft. Printed token: "WD".
      # Example: "W3C WD-charmod-19991129".
      class WorkingDraft < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :wd,
            stage_code: :working_draft,
            type_code: :wd,
            abbr: ["WD"],
            name: "Working Draft",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :wd, web: :working_draft, title: "Working Draft", short: "WD" }
        end

        def type_prefix
          "WD"
        end
      end
    end
  end
end
