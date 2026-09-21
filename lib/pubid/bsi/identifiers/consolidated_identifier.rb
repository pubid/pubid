# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Consolidated Identifier - contains base document plus supplements
      # Example: "BS 4592-0:2006+A1:2012" = [BS 4592-0:2006, Amendment 1:2012]
      class ConsolidatedIdentifier < SingleIdentifier
        include RootIdentity

        attribute :identifiers, ::Pubid::Identifier, polymorphic: true,
                                                     collection: true

        def to_urn
          base = identifiers&.first
          return nil unless base

          urn = base.to_urn if base.class.method_defined?(:to_urn)
          return urn unless urn

          # Append supplement info to URN
          identifiers[1..].each do |id|
            if id.is_a?(Amendment)
              urn += ":amd:#{id.number}"
              urn += ":#{id.year}" if id.year
            elsif id.is_a?(Corrigendum)
              urn += ":cor:#{id.number}"
              urn += ":#{id.year}" if id.year
            end
          end
          urn
        end

        # Delegate to first identifier (base document)
        def publisher
          identifiers&.first&.publisher
        end

        # See Identifiers::Amendment.compact_hash: the publisher is derived
        # from the first member and must stay off the wrapper's own wire entry,
        # or from_hash round-trips regrow it.
        def self.compact_hash(_model, hash)
          hash.delete("publisher")
        end

        # `number`, `part`, `parts`, `date` and `year` are deliberately NOT
        # delegated. They used to read `identifiers.first`, one level only, so
        # they answered with the member's value when that member was a plain
        # standard and with nil when it was itself a wrapper (an adoption) —
        # the same accessor reporting two different things. They also shadowed
        # real lutaml attributes, and the `date` one handed lutaml a foreign
        # `Pubid::Components::Date` where BSI declares its own subclass, which
        # is what made `to_hash` raise.
        #
        # A BSI wrapper owns no identity: `#root` carries it, recursively and
        # for every layer. See `Identifiers::RootIdentity` and
        # docs/flavors/bsi.md.
        def type
          base = identifiers&.first
          base.type if base&.class&.attributes&.key?(:type)
        end

        # Base document = the wrapped standard (first entry), fully peeled.
        def base_document
          identifiers&.first&.base_document || self
        end

        # The origin document. Members live in `identifiers` (not `base`), so
        # walk the first member to its root.
        def root
          identifiers&.first&.root || self
        end

        # Dropping the supplement layer yields the base standard alone.
        def drop_supplements
          identifiers&.first || self
        end
      end
    end
  end
end
