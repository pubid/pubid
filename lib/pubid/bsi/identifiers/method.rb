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
          render(format: :human, lang: lang, lang_single: lang_single)
        end
      end
    end
  end
end
