# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Standalone Amendment identifier (no base reference)
      # Examples: "AMD 11015", "(AMD 10971)", "AMD Corrigendum 14716"
      class StandaloneAmendment < SingleIdentifier
        attribute :amendment_number, Components::Code
        attribute :corrigendum, :boolean, default: false
        attribute :parenthesized, :boolean, default: false

        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :standalone_amendment,
            stage_code: :published,
            type_code: :amendment,
            abbr: ["AMD"],
            name: "Amendment",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :standalone_amendment, title: "Amendment", short: "AMD" }
        end

        def to_s(lang: :en, lang_single: false)
          render(format: :human, lang: lang, lang_single: lang_single)
        end
      end
    end
  end
end
