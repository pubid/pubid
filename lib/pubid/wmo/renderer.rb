# frozen_string_literal: true

module Pubid
  module Wmo
    # Human-readable renderer for WMO identifiers.
    #
    # Produces strings like:
    #   "WMO-No. 1364"
    #   "WMO-No. 1364, 2025 edition"
    #   "S-411"
    #   "S-411 1.2.1"
    #   "S-411 Annex A"
    #
    # The faces carry no publisher token — "WMO-No." is the series
    # designation and the S-number prints bare (the repository form) —
    # so to_s(with_publisher:) is the identity on every type.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        id = @id

        return render_annex(id) if id.is_a?(Identifiers::Annex)
        return render_publication(id) if id.is_a?(Identifiers::Publication)

        rendered = "S-#{id.number}"
        rendered << " #{id.edition}" if id.edition
        rendered
      end

      def render_publication(id)
        rendered = "WMO-No. #{id.number}"
        rendered << ", #{id.edition} edition" if id.edition
        rendered
      end

      # The marker case is preserved verbatim ("Annex" vs "ANNEX").
      def render_annex(id)
        rendered = "S-#{id.base.number} #{id.annex_form}"
        rendered << " #{id.letter}" if id.letter
        rendered << " #{id.edition}" if id.edition
        rendered
      end
    end
  end
end
