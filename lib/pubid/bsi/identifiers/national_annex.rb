# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # National Annex (NA) identifier
      # Can have own supplements: "NA+A1:2012 to BASE"
      class NationalAnnex < SingleIdentifier
        include RootIdentity

        # Supplements on the NA itself. `initialize_empty: true` because the
        # builder always passes an array (empty when the grammar matched no
        # supplement) while `from_hash` never sets the attribute at all — the
        # serialized hash omits an empty collection — so a parsed NA held `[]`
        # and a deserialized one `nil`, and the two were not `==`. `#matches?`
        # is `exclude(*ignore) == other.exclude(*ignore)`, so every index lookup
        # of a supplement-less NA silently returned nothing. The `collection:
        # true` lesson in CLAUDE.md, and the same one-line remedy.
        attribute :na_supplements, ::Pubid::Identifier, polymorphic: true,
                                                        collection: true,
                                                        initialize_empty: true
        # The identifier after "to", under the uniform parent accessor. `#root`
        # and `#base_document` are inherited and walk it, so the delegating
        # readers this class used to carry are gone — they shadowed real lutaml
        # accessors and reached only one level down.
        attribute :base, ::Pubid::Identifier, polymorphic: true

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
      end
    end
  end
end
