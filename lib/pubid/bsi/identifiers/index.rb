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

        def to_s(lang: :en, lang_single: false)
          # Build string representation - Index has special format
          parts = []

          # Publisher (BS)
          parts << publisher.to_s if publisher

          # Number
          if number
            number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s
            parts << number_str
          end

          result = parts.join(" ")

          # Index suffix with colon or space format
          result += if issue_number
                      " Index Issue #{issue_number}"
                    elsif index_format == "colon"
                      ":Index"
                    else
                      " Index"
                    end

          # Date
          if date
            year_val = date.respond_to?(:year) ? date.year : date.to_i
            result += ":#{year_val}"
          end

          result
        end
      end
    end
  end
end
