# frozen_string_literal: true

module Pubid
  module Adobe
    # Human-readable renderer for Adobe identifiers.
    #
    # Produces the canonical citation forms:
    #   "Adobe TN 5014"                       (tech note)
    #   "Adobe Publication adobe-glyph-list"  (publication, slug)
    #   "Adobe Publication adobe-japan1-7"    (publication, slug + version)
    #
    # The data repo (AdobeFetcher::Docid) overrides #to_s for publications
    # to use the title from metadata instead of the slug, producing e.g.
    # "Adobe Publication Adobe Glyph List". Pubid::Adobe itself is purely
    # structural and renders slug-form citations.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        id = @id

        return render_tech_note(id) if id.is_a?(Identifiers::TechNote)
        return render_publication(id) if id.is_a?(Identifiers::Publication)

        raise ArgumentError, "Unknown Adobe identifier class: #{id.class}"
      end

      private

      def render_tech_note(id)
        "Adobe TN #{id.number}"
      end

      def render_publication(id)
        rendered = "Adobe Publication #{id.slug}"
        rendered << "-#{id.version}" if id.version
        rendered
      end
    end
  end
end
