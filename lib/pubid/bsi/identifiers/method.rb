# frozen_string_literal: true


module Pubid
  module Bsi
    module Identifiers
      # BSI Method
      # Examples:
      # - Basic: "BS 2782-1:Method 131B:1983"
      # - Range: "BS 2782-4:Methods 451F to 451J:1978"
      # - And: "BS 2782-8:Methods 823A and 823B:1978"
      class Method < SingleIdentifier
        attribute :method_code, :string     # Main method code (e.g., "131B")
        attribute :method_to, :string       # Second method code for "to" format (e.g., "451J")
        attribute :method_and, :string      # Second method code for "and" format (e.g., "823B")
        attribute :is_plural, :boolean      # Track singular vs plural ("Method" vs "Methods")

        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubmethod,
            stage_code: :published,
            type_code: :method,
            abbr: ["Method", "Methods"],
            name: "Method",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :method, title: "Method", short: "Method" }
        end

        def to_s(lang: :en, lang_single: false)
          # Build string representation - Method has three formats
          parts = []

          # Publisher (BS)
          parts << publisher.to_s if publisher

          # Number with part (e.g., "2782-1")
          if number
            number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s
            # Add part if present (e.g., "2782" + "-" + "1")
            if part
              part_val = part.respond_to?(:value) ? part.value : part
              number_str += "-#{part_val}"
            end
            parts << number_str
          end

          result = parts.join(" ")

          # Method suffix with appropriate format
          if method_to
            # Range format: ":Methods X to Y"
            result += ":Methods #{method_code} to #{method_to}"
          elsif method_and
            # And format: ":Methods X and Y"
            result += ":Methods #{method_code} and #{method_and}"
          else
            # Basic format: singular or plural
            method_word = is_plural ? "Methods" : "Method"
            result += ":#{method_word} #{method_code}"
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
