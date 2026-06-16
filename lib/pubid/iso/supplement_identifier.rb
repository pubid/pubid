# frozen_string_literal: true

module Pubid
  module Iso
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, Identifier,
                polymorphic: true

      key_value do
        # Serialized key is "base" (matches JIS); the attribute/method stays
        # `base_identifier`, which relaton-index's get_id_number depends on.
        map "base", to: :base_identifier, polymorphic: {
          attribute: "_type",
          class_map: Identifier::ISO_TYPE_MAP,
        }
      end

      def publisher
        base_identifier&.publisher
      end

      # A supplement's copublishers are the base's — delegate like #publisher,
      # so a parsed supplement and a from_hash-deserialized one agree (== and
      # index matching compare the copublishers collection).
      def copublishers
        base_identifier&.copublishers
      end

      def to_s(**opts)
        context = build_rendering_context(nil, format: :human, **opts)
        Pubid::Renderers::SupplementRenderer.new(self).render(context:,
                                                              **opts.slice(:with_edition))
      end
    end
  end
end
