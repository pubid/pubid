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
          render(format: :human, lang: lang, lang_single: lang_single)
        end
      end
    end
  end
end
