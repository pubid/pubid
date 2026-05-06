# frozen_string_literal: true

module Pubid
  module Iso
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, Identifier,
        polymorphic: true

      key_value do
        map "base_identifier", to: :base_identifier, polymorphic: {
          attribute: "_type",
          class_map: Identifier::ISO_TYPE_MAP,
        }
      end

      def publisher
        base_identifier&.publisher
      end

      def to_s(**opts)
        context = build_rendering_context(nil, format: :human, **opts)
        Pubid::Renderers::SupplementRenderer.new(self).render(context:, **opts.slice(:with_edition))
      end
    end
  end
end
