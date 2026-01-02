# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # BSI Flex document identifier
      class Flex < SingleIdentifier
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
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
            number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s
            if part
              part_val = part.respond_to?(:value) ? part.value : part
              number_str += "-#{part_val}"
            end
            if subpart
              subpart_val = subpart.respond_to?(:value) ? subpart.value : subpart
              number_str += "-#{subpart_val}"
            end
            parts << number_str
          end

          result = parts.join(" ")

          # Edition comes before date for Flex
          result += " v#{edition}" if edition

          # Date
          if date
            year_val = date.respond_to?(:year) ? date.year : date.to_i
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
