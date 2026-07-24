# frozen_string_literal: true

module Pubid
  module Isbn
    module Identifiers
      # ISBN book identifier — supports both ISBN-10 and ISBN-13.
      #
      # Examples:
      #   ISBN 978-3-16-148410-0
      #   ISBN 0-306-40615-2
      #   9783161484100
      class Book < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubisbn,
            stage_code: :published,
            type_code: :isbn,
            abbr: ["ISBN"],
            name: "ISBN",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :isbn, web: :book, title: "ISBN", short: "ISBN" }
        end
      end
    end
  end
end
