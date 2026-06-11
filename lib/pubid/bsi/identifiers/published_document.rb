# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Published Document (PD) identifier
      class PublishedDocument < SingleIdentifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubpd,
            stage_code: :published,
            type_code: :pd,
            abbr: ["PD"],
            name: "Published Document",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :pd, title: "Published Document", short: "PD" }
        end

        def to_s(lang: :en, lang_single: false)
          render(format: :human, lang: lang, lang_single: lang_single)
        end
      end
    end
  end
end
