# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # BSI Section
      # Examples:
      # - Colon format (DD): "DD 51:Section 0:1977"
      # - Space format (BS): "BS 3224 Section B2:1970"
      class Section < SingleIdentifier
        attribute :section_id, :string # Section identifier (0-7 or B2, C1, D1, etc.)
        attribute :section_format, :string # Preserve ":Section" or " Section" separator

        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubsection,
            stage_code: :published,
            type_code: :section,
            abbr: ["Section"],
            name: "Section",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :section, title: "Section", short: "Section" }
        end

        def to_s(lang: :en, lang_single: false)
          # Build string representation - Section has two formats
          parts = []

          # Publisher (DD, BS, etc.)
          parts << publisher.to_s if publisher

          # Number
          if number
            number_str = number.is_a?(Components::Code) ? number.value.to_s : number.to_s
            parts << number_str
          end

          result = parts.join(" ")

          # Section suffix with colon or space format
          result += if section_format == "colon"
                      ":Section #{section_id}"
                    else
                      " Section #{section_id}"
                    end

          # Date
          if date
            year_val = date.is_a?(Components::Date) ? date.year : date.to_i
            result += ":#{year_val}"
          end

          result
        end
      end
    end
  end
end
