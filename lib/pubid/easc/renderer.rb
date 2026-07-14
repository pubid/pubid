# frozen_string_literal: true

module Pubid
  module Easc
    # Human-readable renderer for EASC identifiers.
    #
    # Produces strings like:
    #   "ПМГ 03-2025"
    #   "ПМГ В 31-2001"      (defense variant)
    #   "РМГ 151-2025"
    #
    # Always renders in Cyrillic — the canonical form used on
    # mgscatalog.by. Latin transliterations (PMG, RMG, V) parse but
    # render to Cyrillic.
    class Renderer < ::Pubid::Renderers::Base
      CYRILLIC_SERIES = {
        "PMG" => "ПМГ",
        "RMG" => "РМГ",
      }.freeze

      CYRILLIC_VARIANT = "В".freeze

      def render(context: nil, **_opts)
        id = @id

        if id.is_a?(Identifiers::Pmg) || id.is_a?(Identifiers::Rmg)
          return render_standard(id)
        end

        raise ArgumentError, "Unknown EASC identifier class: #{id.class}"
      end

      private

      def render_standard(id)
        rendered = +"#{cyrillic_series(id.series)}"
        rendered << " #{CYRILLIC_VARIANT}" if id.variant == "V"
        rendered << " #{id.number}"
        rendered << "-#{id.year}" if id.year
        rendered
      end

      def cyrillic_series(series)
        CYRILLIC_SERIES.fetch(series, series)
      end
    end
  end
end
