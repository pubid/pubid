# frozen_string_literal: true

module Pubid
  module Gost
    # Human-readable renderer for GOST identifiers.
    #
    # Produces strings like:
    #   "GOST 14946-82"
    #   "GOST R 34.12-2015"
    #
    # Always renders in Latin script regardless of input script. The
    # Cyrillic form (ГОСТ) is preserved on parse but normalised to
    # "GOST" on render — the canonical citation form for international
    # audiences is Latin.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        id = @id

        return render_standard(id) if id.is_a?(Identifiers::Standard)

        raise ArgumentError, "Unknown GOST identifier class: #{id.class}"
      end

      private

      def render_standard(id)
        rendered = +"GOST"
        rendered << " R" if id.scope == "russian"
        rendered << " #{id.copublisher}" if id.copublisher
        rendered << " #{id.number}"
        rendered << "-#{id.year}" if id.year
        rendered
      end
    end
  end
end
