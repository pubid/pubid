# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Consolidated Identifier
      # Single Responsibility: Represents a consolidated publication containing multiple documents
      # Example: "IEC 60529:1989+AMD1:1999" contains [IS, AMD] as separate identifier objects
      # This is MODEL-DRIVEN: stores the actual identifiers, not just renders with +
      class ConsolidatedIdentifier < Identifier
        attribute :identifiers, Identifier, polymorphic: true, collection: true

        # Common fields are delegated to identifiers.first, so suppress the
        # inherited common maps and serialize the wrapped identifiers (base
        # document + supplements) instead. Route each nested hash back through
        # Identifier.from_hash so its concrete subclass is reconstructed.
        include Pubid::Iec::DelegatedFieldSuppression

        key_value do
          map "identifiers",
              with: { to: :identifiers_to_kv, from: :identifiers_from_kv }
        end

        def identifiers_to_kv(model, doc)
          return unless model.identifiers&.any?

          doc.add_child(Lutaml::KeyValue::DataModel::Element.new(
                          "identifiers", model.identifiers.map(&:to_hash)
                        ))
        end

        def identifiers_from_kv(model, value)
          model.identifiers = Array(value).map do |h|
            ::Pubid::Iec::Identifier.from_hash(h)
          end
        end

        # Delegate common attributes to first identifier (base document)
        def publisher
          identifiers&.first&.publisher
        end

        def copublishers
          identifiers&.first&.copublishers
        end

        def code
          identifiers&.first&.code
        end

        def number
          identifiers&.first&.number
        end

        def date
          identifiers&.first&.date
        end

        def stage
          identifiers&.first&.stage
        end

        def typed_stage
          identifiers&.first&.typed_stage
        end

        # Get the base document (first identifier), peeled recursively —
        # a consolidated edition of a supplement reduces to its origin
        # standard, the BSI/CSA/CEN shape (the one-level peel left a
        # supplement bundle resolving to the supplement).
        def base_document
          identifiers&.first&.base_document || self
        end

        # The origin document. A consolidated bundle stores its members in
        # `identifiers` (not `base`), so walk the first member to its root.
        def root
          identifiers&.first&.root || self
        end

        # Get all supplements (identifiers after first)
        def supplements
          identifiers&.drop(1) || []
        end

        # Dropping the supplement layer yields the leading member — the base
        # standard alone (the CEN counterpart's shape). This is what makes
        # the structural exclusions reach a consolidated chain:
        # `exclude(:amendment)` / `exclude(:supplement)` and their
        # `matches?(ignore:)` forms peel the composition to the document it
        # supplements, so a consolidated reference matches the bare base
        # record (the primitive relaton-api-js's citation-validation uses to
        # resolve a consolidated docid onto the edition it amends).
        def drop_supplements
          identifiers&.first || self
        end

        # MR string: the base member's own MR (its part/subpart ride on the
        # member, so the slug keeps the full designation), then each
        # supplement member behind a `plus-` marker — the CEN counterpart's
        # composition. Without it the chain rendered the generic flat slug,
        # which both dropped the part and shared one slug with the bare base
        # document (`IEC 60601-1:2005+AMD1:2012 CSV` keyed `iec.60601.2005`,
        # colliding with the part-less rendering of `IEC 60601-2:2005+AMD1:
        # 2012 CSV` and with the base itself). The `plus-` marker keeps the
        # consolidated slug distinct from the standalone supplement chain's
        # (`iec.60601-1.2005_amd.1.2012`), mirroring the CEN ruling that a
        # consolidated form must not share a slug with the document it
        # composes.
        def to_mr_string
          base, *supplements = identifiers
          return "" unless base

          ([base.to_mr_string] +
            supplements.filter_map do |member|
              suffix = member.mr_supplement_suffix
              "plus-#{suffix}" if suffix
            end).join(Pubid::Renderers::MrString::SEPARATOR_SUPPLEMENT)
        end
      end
    end
  end
end
