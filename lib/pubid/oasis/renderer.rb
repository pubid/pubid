# frozen_string_literal: true

module Pubid
  module Oasis
    # Human-readable renderer for OASIS identifiers.
    #
    # Renders the verbatim slug (`original`), prefixed with the "OASIS "
    # publisher token unless `id.with_publisher == false`. Because rendering is
    # a pure echo of `original`, the printed form always round-trips exactly.
    #
    #   "OASIS OSLC-CoreShapes-3.0-PS01-Pt8"  (with publisher)
    #   "OSLC-CoreShapes-3.0-PS01-Pt8"        (without)
    class Renderer < ::Pubid::Renderers::Base
      PUBLISHER = "OASIS"

      def render(context: nil, **opts)
        id = @id
        body = id.original.to_s
        with_publisher?(id) ? "#{PUBLISHER} #{body}" : body
      end

      private

      def with_publisher?(id)
        id.with_publisher != false
      end
    end
  end
end
