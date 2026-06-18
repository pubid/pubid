# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # TechnicalSpecification represents BSI technical specifications
      # Format: TS {number}:{year}
      #
      # Examples:
      #   TS 3:1993
      #   TS 1:1998
      #   TS 1:1995
      class TechnicalSpecification < SingleIdentifier
        # TYPED_STAGES for technical specifications (published by default)
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubts,
            stage_code: :published,
            type_code: :ts,
            abbr: ["TS"],
            name: "Technical Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :ts,
            web: :technical_specification, title: "Technical Specification", short: "TS" }
        end

        def to_s(lang: :en, lang_single: false)
          render(format: :human, lang: lang, lang_single: lang_single)
        end
      end
    end
  end
end
