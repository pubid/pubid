# frozen_string_literal: true

module Pubid
  module Wmo
    # Human-readable renderer for WMO identifiers.
    #
    # Produces strings like:
    #   "WMO-No. 1364"
    #   "WMO-No. 1364, 2025 edition"
    #   "WMO-No. 8, Volume I"
    #   "WMO-No. 306, Volume I.1, 2020 edition"
    #   "WMO-No. 8, 2021/2018 edition"
    #   "WMO-No. 1364, 2023 edition, updated in 2025"
    #   "WMO-No. 8, Provisional 2026 edition"
    #   "WMO/TD-No. 196"
    #   "JCOMM Technical Report No. 14"
    #   "GAW Report No. 312"
    #   "S-411"
    #   "S-411 1.2.1"
    #   "S-411 Annex A"
    #
    # The faces carry no publisher token — the series head ("WMO-No.",
    # "WMO/TD-No.", ...) is the designation and the S-number prints bare
    # (the repository form) — so to_s(with_publisher:) is the identity
    # on every type. The face order is the widening ruling's: volume
    # first, then the edition face (status word inside it), then the
    # updated-in year.
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
        rendered = "#{id.series_config[:face]} #{id.number}"
        rendered << ", Volume #{id.volume}" if id.volume
        if id.edition
          rendered << if id.edition_status
                        ", #{id.edition_status} #{id.edition} edition"
                      else
                        ", #{id.edition} edition"
                      end
          rendered << ", updated in #{id.updated_in}" if id.updated_in
        end
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
