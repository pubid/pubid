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

      # A supplement carries the publisher/copublishers of the document it
      # supplements. Delegate to the root rather than the immediate base so a
      # nested supplement (e.g. ".../Amd 1/Cor 1") reads identity from the
      # underlying standard in one hop, regardless of chain depth. This keeps a
      # parsed supplement and a from_hash-deserialized one in agreement (== and
      # index matching compare both). Guard on base_identifier: `root` returns
      # self when there is no base, which would otherwise recurse forever.
      def publisher
        root.publisher if base_identifier
      end

      def copublishers
        root.copublishers if base_identifier
      end

      def to_s(**opts)
        context = build_rendering_context(nil, format: :human, **opts)
        Pubid::Renderers::SupplementRenderer.new(self).render(context:,
                                                              **opts.slice(:with_edition))
      end
    end
  end
end
