# frozen_string_literal: true

module Pubid
  module Ogc
    module Identifiers
      # The sole OGC identifier type. An OGC document is numbered
      # `<yy>-<nnn>[<revision>]` with no publisher token in the printed form.
      class Document < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :ogc,
            stage_code: :published,
            type_code: :ogc,
            abbr: ["OGC"],
            name: "OGC Document",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :ogc, web: :document, title: "OGC Document", short: "OGC" }
        end
      end
    end
  end
end
