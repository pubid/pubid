# frozen_string_literal: true

module Pubid
  module CenCenelec
    module Identifiers
      # Consolidated Identifier - contains base document plus supplements
      # Example: "EN 196-3:2005+A1:2008" = [EN 196-3:2005, Amendment(base + params)]
      #
      # It descends from the shared Pubid::CenCenelec::Identifier, not from
      # the legacy Identifiers::Base. It used to inherit Base's publisher,
      # number, year, parts and type attributes and to override each of them
      # with a reader that delegated to the first member. `#exclude` and the
      # serializer read every attribute through its reader, so they reached
      # `EuropeanNorm#parts`, which does not exist, and raised. Read the base
      # document through #base_document instead.
      class ConsolidatedIdentifier < Pubid::CenCenelec::Identifier
        attribute :identifiers, Pubid::CenCenelec::Identifier,
                  polymorphic: true, collection: true

        # The origin document. Members live in `identifiers` (not `base`), so
        # walk the first member to its root.
        def root
          identifiers&.first&.root || self
        end

        def base_document
          identifiers&.first&.base_document || self
        end

        # Dropping the supplement layer yields the base standard alone.
        def drop_supplements
          identifiers&.first || self
        end

        # "en.285.2015_plus-amd.1.2021": the base document, then each member's
        # own supplement suffix behind a "plus" marker, so the consolidated
        # form does not share a slug with the standalone "EN 285:2015/A1:2021".
        def to_mr_string
          base, *supplements = identifiers
          return "" unless base

          ([base.to_mr_string] +
            supplements.map { |s| "plus-#{s.mr_supplement_suffix}" })
            .join(Renderers::MrString::SEPARATOR_SUPPLEMENT)
        end
      end
    end
  end
end
