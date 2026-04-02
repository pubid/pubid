require "lutaml/model"
# frozen_string_literal: true

module Pubid
  module Cen
    module Identifiers
      class TechnicalReport < SingleIdentifier
        attribute :type, Components::Type, default: -> { self.class.type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubtr,
            stage_code: :published,
            type_code: :tr,
            abbr: ["TR"],
            name: "Technical Report",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :tr, title: "Technical Report", short: "TR" }
        end
      end
    end
  end
end
