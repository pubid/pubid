# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Publicly Available Specification (PAS) identifier
      class PubliclyAvailableSpecification < SingleIdentifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubpas,
            stage_code: :published,
            type_code: :pas,
            abbr: ["PAS"],
            name: "Publicly Available Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :pas, title: "Publicly Available Specification", short: "PAS" }
        end

        def to_s(lang: :en, lang_single: false)
          render(format: :human, lang: lang, lang_single: lang_single)
        end
      end
    end
  end
end
