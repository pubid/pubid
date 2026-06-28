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

        # Get the base document (first identifier)
        def base_document
          identifiers&.first
        end

        # Get all supplements (identifiers after first)
        def supplements
          identifiers&.drop(1) || []
        end
      end
    end
  end
end
