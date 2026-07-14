# frozen_string_literal: true

module Pubid
  module Ogc
    # Human-readable renderer for OGC identifiers.
    #
    # Produces the canonical printed form, e.g.:
    #   "24-032r1"
    #   "01-009a"
    #   "OGC 24-032r1"   (only when with_publisher: true)
    #
    # Registered as the `:human` format in the OGC format registry and invoked
    # via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      PUBLISHER = "OGC"

      def render(**_opts)
        id = @id
        result = +""
        result << "#{PUBLISHER} " if with_publisher?(id)
        result << "#{id.year}-#{id.number}"
        result << id.revision.to_s if id.revision
        result
      end

      private

      def with_publisher?(id)
        id.respond_to?(:with_publisher) && id.with_publisher == true
      end
    end
  end
end
