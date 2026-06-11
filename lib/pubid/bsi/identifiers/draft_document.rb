# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Draft Document (DD) identifier
      class DraftDocument < SingleIdentifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubdd,
            stage_code: :published,
            type_code: :dd,
            abbr: ["DD"],
            name: "Draft Document",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :dd, title: "Draft Document", short: "DD" }
        end

        def to_s(lang: :en, lang_single: false)
          render(format: :human, lang: lang, lang_single: lang_single)
        end
      end
    end
  end
end
