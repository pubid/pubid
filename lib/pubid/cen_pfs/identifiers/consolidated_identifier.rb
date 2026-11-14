module Pubid
  module CenPfs
    module Identifiers
      # The consolidated (plus-run) bundle: the base document is
      # the first member; the supplements carry no base.
      class ConsolidatedIdentifier < ::Pubid::CenPfs::Identifier
        attribute :identifiers, ::Pubid::CenPfs::Identifier,
                  polymorphic: true, collection: true

        # The origin document. Members live in `identifiers`, so
        # walk the first member to its root.
        def root
          identifiers&.first&.root || self
        end

        def base_document
          identifiers&.first&.base_document || self
        end

        def drop_supplements
          identifiers&.first || self
        end

        # The base document, then each member's own supplement
        # suffix behind the plus marker — the coded shape.
        def to_mr_string
          base, *supplements = identifiers
          return "" unless base

          ([base.to_mr_string] +
            supplements.map { |s| "plus-#{s.mr_supplement_suffix}" })
            .join(::Pubid::Renderers::MrString::SEPARATOR_SUPPLEMENT)
        end

        def self.polymorphic_name
          "pubid:cencenelec:consolidated-identifier"
        end
      end
    end
  end
end
