# frozen_string_literal: true

module Pubid
  module Evs
    # Human-readable renderer for EVS identifiers.
    #
    # Produces strings like:
    #   "EVS-EN 18216:2026"
    #   "EVS-EN ISO 14001:2026"
    #   "EVS-EN ISO/IEC 27017:2026"
    #   "EVS-EN ISO 9001:2015/A1:2024"
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        # The adopted identifier renders with its own "EN …" prefix, so the
        # national prefix composes as "EVS" + separator + adopted.
        "EVS#{separator}#{adopted}"
      end

      private

      def separator
        @id.separator || "-"
      end

      def adopted
        @id.adopted_identifier.to_s
      end
    end
  end
end
