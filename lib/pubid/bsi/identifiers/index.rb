# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # BSI Index
      # Examples: "BS 5000:Index:1981", "BS 185 Index:1964", "BS 5000 Index Issue 4:1980"
      class Index < SingleIdentifier
        attribute :issue_number, :string  # For "Index Issue N" format
        attribute :index_format, :string  # Preserve ":Index" or " Index" separator

        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :index,
            stage_code: :published,
            type_code: :index,
            abbr: ["Index"],
            name: "Index",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :index, title: "Index", short: "Index" }
        end

      end
    end
  end
end
