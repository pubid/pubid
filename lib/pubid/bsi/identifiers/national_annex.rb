# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # National Annex (NA) identifier
      # Can have own supplements: "NA+A1:2012 to BASE"
      class NationalAnnex < SingleIdentifier
        attribute :na_supplements, ::Pubid::Identifier, polymorphic: true, collection: true # Supplements on the NA itself
        attribute :base_doc, ::Pubid::Identifier, polymorphic: true # The identifier after "to"

        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubna,
            stage_code: :published,
            type_code: :na,
            abbr: ["NA"],
            name: "National Annex",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :na,
            web: :national_annex, title: "National Annex", short: "NA" }
        end

        # Delegation methods to access wrapped base_doc attributes
        def number
          base_doc&.number || super
        end

        def date
          base_doc&.date || super
        end

        def part
          base_doc&.part || super
        end

        def subpart
          base_doc&.subpart || super
        end

        def to_s(lang: :en, lang_single: false)
          render(format: :human, lang: lang, lang_single: lang_single)
        end
      end
    end
  end
end
