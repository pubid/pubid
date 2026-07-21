# frozen_string_literal: true

module Pubid
  module Ccsds
    # Base class for CCSDS supplements (corrigenda, amendments, etc.).
    # Descends from the abstract root (not the concrete Base) and points
    # `base` at the root, so the polymorphic attribute never
    # resolves to its own superclass — which is what prevents lutaml from
    # recursing forever while building a supplement from a hash.
    class SupplementIdentifier < Identifier
      attribute :base, Identifier, polymorphic: true

      # Serialize the supplemented identifier under "base" (matches ISO/JIS).
      # The key stays `base` for the attribute/getter, which
      # relaton-index's get_id_number relies on. A supplement's own code
      # attributes (number/part/edition/...) stay nil — they live inside
      # `base` — so the merged root key_value omits them here, keeping the
      # serialization lean and non-duplicated.
      key_value do
        map "base", to: :base
      end

      def <=>(other)
        return nil unless other.is_a?(SupplementIdentifier)

        # Compare base identifiers first
        if base && other.base
          base_cmp = base <=> other.base
          return base_cmp unless base_cmp.zero?
        end

        # Subclasses should implement more specific comparison
        0
      end
    end
  end
end
