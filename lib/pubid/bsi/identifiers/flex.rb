# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # BSI Flex document identifier
      class Flex < SingleIdentifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubflex,
            stage_code: :published,
            type_code: :flex,
            abbr: ["Flex", "BSI Flex"],
            name: "BSI Flex",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :flex, title: "BSI Flex", short: "BSI Flex" }
        end

        # Base document = the Flex standard without its version (edition).
        def base_document
          exclude(:edition)
        end
      end
    end
  end
end
