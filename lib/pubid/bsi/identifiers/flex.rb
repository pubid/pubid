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

        def to_s(lang: :en, lang_single: false)
          parts = []

          # Publisher is always "BSI Flex"
          parts << "BSI Flex"

          # Number with part/subpart
          if number
            number_str = number.is_a?(Components::Code) ? number.value.to_s : number.to_s
            if part
              part_val = part.is_a?(Components::Code) ? part.value : part
              number_str += "-#{part_val}"
            end
            if subpart
              subpart_val = subpart.is_a?(Components::Code) ? subpart.value : subpart
              number_str += "-#{subpart_val}"
            end
            parts << number_str
          end

          result = parts.join(" ")

          # Edition comes before date for Flex
          result += " v#{edition}" if edition

          # Date
          if date
            year_val = date.is_a?(Components::Date) ? date.year : date.to_i
            result += ":#{year_val}"
            # Month if present
            result += "-#{format('%02d', month)}" if month
          end

          result
        end
      end
    end
  end
end
