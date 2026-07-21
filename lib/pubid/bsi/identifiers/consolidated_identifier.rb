# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Consolidated Identifier - contains base document plus supplements
      # Example: "BS 4592-0:2006+A1:2012" = [BS 4592-0:2006, Amendment 1:2012]
      class ConsolidatedIdentifier < SingleIdentifier
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
              urn += ":amd:#{id.amendment_number}"
              urn += ":#{id.amendment_year}" if id.amendment_year
            elsif id.is_a?(Corrigendum)
              urn += ":cor:#{id.corrigendum_number}"
              urn += ":#{id.corrigendum_year}" if id.corrigendum_year
            end
          end
          urn
        end

        # Delegate to first identifier (base document)
        def publisher
          identifiers&.first&.publisher
        end

        def number
          identifiers&.first&.number
        end

        def year
          base = identifiers&.first
          base.year if base&.class&.attributes&.key?(:year)
        end

        def date
          base = identifiers&.first
          base.date if base&.class&.attributes&.key?(:date)
        end

        def parts
          base = identifiers&.first
          base.parts if base&.class&.attributes&.key?(:parts)
        end

        def part
          base = identifiers&.first
          base.part if base&.class&.attributes&.key?(:part)
        end

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
